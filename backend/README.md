# Backend

Backend services for Offload.

## Structure

- `api/` - API server
  - `src/` - Source code
  - `tests/` - Tests
- `infra/` - Infrastructure as code (Terraform/Pulumi)

## API Endpoints

- Python + FastAPI backend for AI routing and session management.
- Privacy default: cloud processing requires explicit opt-in and content is not retained.

| Endpoint | Description |
| --- | --- |
| `GET /v1/health` | Health check and build metadata |
| `POST /v1/sessions/anonymous` | Issue anonymous device session token |
| `POST /v1/auth/apple` | Apple Sign-In authentication |
| `POST /v1/ai/breakdown/generate` | Smart Task Breakdown |
| `POST /v1/ai/braindump/compile` | Brain Dump Compiler |
| `POST /v1/ai/decide/recommend` | Decision Fatigue Reducer |
| `POST /v1/ai/executive-function/prompt` | Executive Function Prompts |
| `POST /v1/ai/draft/generate` | Communication Draft |
| `POST /v1/usage/reconcile` | Reconcile local usage with server |

Protected endpoints require a bearer session token. AI endpoints use OpenAI or
Anthropic providers behind an adapter interface (configured via
`OFFLOAD_AI_PROVIDER`).

## Local Development

```bash
python3 -m pip install -e 'backend/api[dev]'
python3 -m ruff check backend/api/src backend/api/tests
python3 -m ty check backend/api/src backend/api/tests
python3 -m pytest backend/api/tests -q
```

## Run API Locally

```bash
python3 -m uvicorn offload_backend.main:app --app-dir backend/api/src --reload
```

### Environment Variables

- `OFFLOAD_SESSION_SECRET` - HMAC secret for anonymous session tokens.
- `OFFLOAD_SESSION_TTL_SECONDS` - Session TTL in seconds.
- `OFFLOAD_OPENAI_API_KEY` - OpenAI API key (required for cloud generation).
- `OFFLOAD_OPENAI_MODEL` - OpenAI model name.
- `OFFLOAD_MAX_INPUT_CHARS` - Max input size accepted by breakdown endpoint.
- `OFFLOAD_DEFAULT_FEATURE_QUOTA` - Feature usage quota used by reconciliation.
