from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor

from offload_backend.usage_store import InMemoryUsageStore, SQLiteUsageStore


def test_sqlite_usage_store_persists_across_restart(tmp_path):
    db_path = tmp_path / "usage.sqlite3"

    first_store = SQLiteUsageStore(db_path=str(db_path))
    first = first_store.reconcile(install_id="install-1", feature="breakdown", local_count=4)
    assert first == 4
    first_store.close()

    second_store = SQLiteUsageStore(db_path=str(db_path))
    second = second_store.reconcile(install_id="install-1", feature="breakdown", local_count=2)
    assert second == 4
    assert second_store.dump() == {("install-1", "breakdown"): 4}
    second_store.close()


def test_in_memory_get_total_count_sums_across_features():
    store = InMemoryUsageStore()
    store.reconcile(install_id="inst-1", feature="breakdown", local_count=3)
    store.reconcile(install_id="inst-1", feature="braindump", local_count=5)
    store.reconcile(install_id="inst-1", feature="decide", local_count=2)
    store.reconcile(install_id="inst-2", feature="breakdown", local_count=99)

    total = store.get_total_count(
        install_id="inst-1", features=["breakdown", "braindump", "decide"]
    )
    assert total == 10


def test_in_memory_get_total_count_empty_features():
    store = InMemoryUsageStore()
    store.reconcile(install_id="inst-1", feature="breakdown", local_count=5)
    assert store.get_total_count(install_id="inst-1", features=[]) == 0


def test_in_memory_increment_increases_count():
    store = InMemoryUsageStore()
    store.increment(install_id="inst-1", feature="breakdown")
    store.increment(install_id="inst-1", feature="breakdown")
    store.increment(install_id="inst-1", feature="braindump")

    assert store.get_total_count(install_id="inst-1", features=["breakdown", "braindump"]) == 3


def test_sqlite_get_total_count_sums_across_features(tmp_path):
    db_path = tmp_path / "usage.sqlite3"
    store = SQLiteUsageStore(db_path=str(db_path))

    store.reconcile(install_id="inst-1", feature="breakdown", local_count=4)
    store.reconcile(install_id="inst-1", feature="braindump", local_count=6)
    store.reconcile(install_id="inst-1", feature="decide", local_count=1)
    store.reconcile(install_id="inst-2", feature="breakdown", local_count=50)

    total = store.get_total_count(
        install_id="inst-1", features=["breakdown", "braindump", "decide"]
    )
    assert total == 11
    store.close()


def test_sqlite_increment_increases_count(tmp_path):
    db_path = tmp_path / "usage.sqlite3"
    store = SQLiteUsageStore(db_path=str(db_path))

    store.increment(install_id="inst-1", feature="breakdown")
    store.increment(install_id="inst-1", feature="breakdown")
    store.increment(install_id="inst-1", feature="braindump")

    assert store.get_total_count(install_id="inst-1", features=["breakdown", "braindump"]) == 3
    store.close()


def test_sqlite_increment_is_atomic_under_concurrency(tmp_path):
    db_path = tmp_path / "usage.sqlite3"
    store_a = SQLiteUsageStore(db_path=str(db_path))
    store_b = SQLiteUsageStore(db_path=str(db_path))

    def _increment(i: int) -> None:
        target = store_a if i % 2 == 0 else store_b
        target.increment(install_id="inst-1", feature="breakdown")

    with ThreadPoolExecutor(max_workers=16) as pool:
        list(pool.map(_increment, range(160)))

    final = store_a.get_total_count(install_id="inst-1", features=["breakdown"])
    assert final == 160

    store_a.close()
    store_b.close()


def test_sqlite_usage_store_reconcile_is_atomic_under_concurrency(tmp_path):
    db_path = tmp_path / "usage.sqlite3"
    store_a = SQLiteUsageStore(db_path=str(db_path))
    store_b = SQLiteUsageStore(db_path=str(db_path))

    def _reconcile(local_count: int):
        target = store_a if local_count % 2 == 0 else store_b
        return target.reconcile(
            install_id="install-1",
            feature="breakdown",
            local_count=local_count,
        )

    with ThreadPoolExecutor(max_workers=16) as pool:
        list(pool.map(_reconcile, range(0, 50)))

    final_count = store_a.reconcile(install_id="install-1", feature="breakdown", local_count=0)
    assert final_count == 49

    store_a.close()
    store_b.close()
