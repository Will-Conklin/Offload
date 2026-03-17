from __future__ import annotations

import sqlite3
import uuid
from dataclasses import dataclass
from pathlib import Path
from threading import Lock
from typing import Protocol


@dataclass(frozen=True)
class UserRecord:
    user_id: str
    apple_user_id: str
    install_id: str
    display_name: str | None


class UserStore(Protocol):
    def upsert_by_apple_id(
        self,
        *,
        apple_user_id: str,
        install_id: str,
        display_name: str | None,
    ) -> UserRecord: ...

    def get_by_apple_id(self, apple_user_id: str) -> UserRecord | None: ...

    def close(self) -> None: ...


class SQLiteUserStore:
    """Persists Offload user identities in a SQLite database.

    Uses the same db_path as SQLiteUsageStore so all persistent state lives
    in one file. The table schema is bootstrapped on first access.
    """

    def __init__(self, *, db_path: str):
        self._lock = Lock()
        self._connection = self._open_connection(db_path=db_path)
        self._bootstrap_schema()

    def _open_connection(self, *, db_path: str) -> sqlite3.Connection:
        if db_path != ":memory:":
            Path(db_path).expanduser().resolve().parent.mkdir(parents=True, exist_ok=True)
        connection = sqlite3.connect(db_path, check_same_thread=False)
        connection.execute("PRAGMA journal_mode=WAL")
        connection.execute("PRAGMA busy_timeout=5000")
        return connection

    def _bootstrap_schema(self) -> None:
        with self._lock:
            self._connection.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                    user_id TEXT PRIMARY KEY,
                    apple_user_id TEXT UNIQUE NOT NULL,
                    install_id TEXT NOT NULL,
                    display_name TEXT,
                    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """,
            )
            self._connection.commit()

    def upsert_by_apple_id(
        self,
        *,
        apple_user_id: str,
        install_id: str,
        display_name: str | None,
    ) -> UserRecord:
        """Find or create a user by Apple user ID.

        On conflict, updates install_id and display_name (preserving existing
        display_name when the new value is None).

        Returns the authoritative UserRecord after the upsert.
        """
        new_id = str(uuid.uuid4())
        with self._lock:
            self._connection.execute("BEGIN IMMEDIATE")
            self._connection.execute(
                """
                INSERT INTO users (user_id, apple_user_id, install_id, display_name)
                VALUES (?, ?, ?, ?)
                ON CONFLICT(apple_user_id) DO UPDATE SET
                    install_id = excluded.install_id,
                    display_name = COALESCE(excluded.display_name, users.display_name)
                """,
                (new_id, apple_user_id, install_id, display_name),
            )
            row = self._connection.execute(
                "SELECT user_id, apple_user_id, install_id, display_name FROM users"
                " WHERE apple_user_id = ?",
                (apple_user_id,),
            ).fetchone()
            self._connection.commit()

        if row is None:
            raise RuntimeError("failed to upsert user record")

        return UserRecord(
            user_id=str(row[0]),
            apple_user_id=str(row[1]),
            install_id=str(row[2]),
            display_name=str(row[3]) if row[3] is not None else None,
        )

    def get_by_apple_id(self, apple_user_id: str) -> UserRecord | None:
        """Return the UserRecord for the given Apple user ID, or None if not found."""
        with self._lock:
            row = self._connection.execute(
                "SELECT user_id, apple_user_id, install_id, display_name FROM users"
                " WHERE apple_user_id = ?",
                (apple_user_id,),
            ).fetchone()

        if row is None:
            return None

        return UserRecord(
            user_id=str(row[0]),
            apple_user_id=str(row[1]),
            install_id=str(row[2]),
            display_name=str(row[3]) if row[3] is not None else None,
        )

    def close(self) -> None:
        with self._lock:
            self._connection.close()
