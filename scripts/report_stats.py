#!/usr/bin/env python3
import pandas as pd, pathlib, rich

m_dir = pathlib.Path(__file__).parent.parent / "metrics"
cpu = pd.read_csv(m_dir / "cpu.csv")
io  = pd.read_csv(m_dir / "io.csv")

rich.print("[bold underline]Top CPU >80 % user+system")
hot_cpu = cpu.assign(total=cpu.user+cpu.system)\
             .query("total>80").sort_values("total", ascending=False).head()
rich.print(hot_cpu)

rich.print("\n[bold underline]Top I/O util >90 %")
hot_io = io.query("util>90").sort_values("util", ascending=False).head()
rich.print(hot_io)
