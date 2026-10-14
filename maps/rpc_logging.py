"""Simple application-level Cynapsa message logs.

Kept in each entity directory so it can be copied and built independently.
These are observations, not transport delivery receipts or SDK event consumers.
"""

from __future__ import annotations

import functools
import inspect
import json
import logging
import os
from contextlib import contextmanager


LOG = logging.getLogger("demo.cynapsa")


def configure_logging() -> None:
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    # Keep useful warnings/errors without access logs for LLM/Places calls.
    for name in ("httpx", "httpcore", "urllib3", "requests"):
        logging.getLogger(name).setLevel(logging.WARNING)


def _peer(identity):
    for name in ("client", "orchestrator", "maps", "files"):
        if identity and identity == os.environ.get(f"DEMO_{name.upper()}_AGENT_ID"):
            return name
    return identity or "unknown"


def _content(value):
    body = getattr(value, "body", value)
    if isinstance(body, bytes):
        decoded = body.decode("utf-8", errors="replace")
        try:
            body = json.loads(decoded)
        except ValueError:
            body = decoded
    return json.dumps(body, ensure_ascii=False, default=str)


@contextmanager
def _traffic(role, *, incoming, peer, path, content, mode="rpc"):
    del role, path, mode
    target = _peer(peer)
    LOG.info('[cynapsa] message %s %s "%s": %s',
             "received" if incoming else "sent",
             "from" if incoming else "to", target, _content(content))
    outcome = {}
    try:
        yield outcome
    except BaseException as exc:
        LOG.warning('[cynapsa] message %s "%s" failed: %s: %s',
                    "from" if incoming else "to", target,
                    type(exc).__name__, exc)
        raise
    else:
        if not incoming:
            LOG.info('[cynapsa] message received from "%s": %s',
                     target, _content(outcome.get("value")))


def log_handler(role):
    """Wrap before @session.on; preserve async dispatch and exceptions unchanged."""
    def decorate(handler):
        def traffic(request):
            return _traffic(role, incoming=True,
                            peer=getattr(request, "from_agent_id", None),
                            path=getattr(request, "path", None),
                            content=getattr(request, "body", None),
                            mode=getattr(request, "mode", None) or "rpc")

        if inspect.iscoroutinefunction(handler):
            @functools.wraps(handler)
            async def async_handler(request):
                with traffic(request) as outcome:
                    outcome["value"] = await handler(request)
                    return outcome["value"]
            return async_handler

        @functools.wraps(handler)
        def sync_handler(request):
            with traffic(request) as outcome:
                outcome["value"] = handler(request)
                return outcome["value"]
        return sync_handler
    return decorate


def request_sync(session, role, target, payload, **options):
    with _traffic(role, incoming=False, peer=target, path=options.get("path"),
                  content=payload) as outcome:
        outcome["value"] = session.request(target, payload, **options)
        return outcome["value"]


async def request_async(session, role, target, payload, **options):
    with _traffic(role, incoming=False, peer=target, path=options.get("path"),
                  content=payload) as outcome:
        outcome["value"] = await session.request(target, payload, **options)
        return outcome["value"]
