#!/usr/bin/env python3
import socket, time, sys, typer, httpx, rich

app = typer.Typer(add_completion=False)

def exit_fail(msg: str, code: int = 1):
    rich.print(f"[bold red]FAIL[/]: {msg}")
    sys.exit(code)

@app.command()
def main(
    http: str = typer.Option(None, help="URL a chequear"),
    tcp: str = typer.Option(None, help="host:port a chequear"),
    timeout: float = typer.Option(2.0, help="timeout en segundos")
):
    if not http and not tcp:
        exit_fail("Debes indicar --http o --tcp", 2)

    start = time.perf_counter()

    if http:
        try:
            r = httpx.get(http, timeout=timeout)
            elapsed = (time.perf_counter() - start) * 1000
            if 200 <= r.status_code < 400:
                rich.print(f"[bold green]OK[/] {int(elapsed)} ms – code {r.status_code}")
                sys.exit(0)
            else:
                exit_fail(f"HTTP {r.status_code}")
        except Exception as e:
            exit_fail(str(e))
    else:
        host, port = tcp.split(":")
        try:
            with socket.create_connection((host, int(port)), timeout=timeout):
                elapsed = (time.perf_counter() - start) * 1000
                rich.print(f"[bold green]OK[/] {int(elapsed)} ms – TCP")
                sys.exit(0)
        except Exception as e:
            exit_fail(str(e))

if __name__ == "__main__":
    app()
