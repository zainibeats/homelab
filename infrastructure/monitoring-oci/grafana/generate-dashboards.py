#!/usr/bin/env python3
"""Generate the OCI Host dashboards (overview + containers). Run it after editing: python3 grafana/generate-dashboards.py"""
import json, os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dashboards", "OCI")
PROM = {"type": "prometheus", "uid": "prometheus"}
LOKI = {"type": "loki", "uid": "loki"}

# Validated categorical palette (dark steps), fixed per compose project so colour follows the entity
PROJECT_COLORS = {
    "netbird": "#3987e5", "matrix": "#d95926", "minecraft": "#199e70", "monitoring-oci": "#c98500",
    "netbird-client": "#d55181", "watchtower": "#008300", "ddclient": "#9085e9", "contagent": "#e66767",
}
GOOD, WARN, CRIT = "#0ca30c", "#fab219", "#d03b3b"
SINGLE = "#3987e5"  # one-series panels use slot 1

PROJ = "container_label_com_docker_compose_project"
NIC, DISK = 'device="enp0s6"', 'device="sda"'

_id = [0]
def nid():
    _id[0] += 1
    return _id[0]

def pos(x, y, w, h):
    return {"x": x, "y": y, "w": w, "h": h}

def prom(expr, legend="", ref="A", instant=False, fmt="time_series"):
    t = {"datasource": PROM, "expr": expr, "legendFormat": legend, "refId": ref, "format": fmt}
    if instant:
        t.update(instant=True, range=False)
    return t

def thresholds(*steps):
    return {"mode": "absolute", "steps": [{"color": c, "value": v} for v, c in steps]}

STATUS_PCT = thresholds((None, GOOD), (80, WARN), (90, CRIT))

def row(title, y, collapsed=False):
    return {"type": "row", "id": nid(), "title": title, "gridPos": pos(0, y, 24, 1), "collapsed": collapsed, "panels": []}

def stat(title, targets, gp, unit="none", decimals=None, status=None, desc="", graph=False):
    d = {"unit": unit, "color": {"mode": "thresholds" if status else "fixed", "fixedColor": "text"},
         "thresholds": status or thresholds((None, "text"))}
    if decimals is not None:
        d["decimals"] = decimals
    return {"type": "stat", "id": nid(), "title": title, "description": desc, "datasource": PROM, "gridPos": gp,
            "targets": targets, "fieldConfig": {"defaults": d, "overrides": []},
            "options": {"reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": False},
                        "colorMode": "value", "graphMode": "area" if graph else "none", "textMode": "value",
                        "justifyMode": "center", "orientation": "auto", "wideLayout": True}}

def ts(title, targets, gp, unit, stack=False, calcs=("mean", "max", "lastNotNull"), mn=None, mx=None,
       overrides=None, desc="", single=False, legend="table", placement="bottom", fill=0, ds=PROM,
       draw="line", negative_y=None):
    custom = {"drawStyle": draw, "lineWidth": 2 if single else 1, "fillOpacity": 60 if draw == "bars" else fill,
              "gradientMode": "none", "showPoints": "never", "spanNulls": False, "axisSoftMin": 0,
              "stacking": {"mode": "normal" if stack else "none", "group": "A"},
              "axisBorderShow": False, "lineInterpolation": "linear"}
    d = {"unit": unit, "custom": custom,
         "color": {"mode": "fixed", "fixedColor": SINGLE} if single else {"mode": "palette-classic"}}
    if mn is not None: d["min"] = mn
    if mx is not None: d["max"] = mx
    ov = list(overrides or [])
    if negative_y:
        ov.append({"matcher": {"id": "byRegexp", "options": negative_y},
                   "properties": [{"id": "custom.transform", "value": "negative-Y"}]})
    lg = {"showLegend": not single, "displayMode": legend, "placement": placement, "calcs": list(calcs) if not single else []}
    return {"type": "timeseries", "id": nid(), "title": title, "description": desc, "datasource": ds, "gridPos": gp,
            "targets": targets, "fieldConfig": {"defaults": d, "overrides": ov},
            "options": {"legend": lg, "tooltip": {"mode": "single" if single else "multi", "sort": "desc"}}}

def project_color_overrides():
    return [{"matcher": {"id": "byName", "options": p},
             "properties": [{"id": "color", "value": {"mode": "fixed", "fixedColor": c}}]}
            for p, c in PROJECT_COLORS.items()]

def bargauge(title, targets, gp, unit, status=None, desc="", mx=None, ds=PROM):
    d = {"unit": unit, "min": 0,
         "color": {"mode": "thresholds"} if status else {"mode": "fixed", "fixedColor": SINGLE},
         "thresholds": status or thresholds((None, SINGLE))}
    if mx is not None: d["max"] = mx
    return {"type": "bargauge", "id": nid(), "title": title, "description": desc, "datasource": ds, "gridPos": gp,
            "targets": targets, "fieldConfig": {"defaults": d, "overrides": []},
            "options": {"displayMode": "basic", "orientation": "horizontal", "showUnfilled": True,
                        "valueMode": "text", "namePlacement": "left", "sizing": "auto", "minVizHeight": 16,
                        "maxVizHeight": 24, "legend": {"showLegend": False},
                        "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": False}}}

def logs(title, targets, gp, desc=""):
    return {"type": "logs", "id": nid(), "title": title, "description": desc, "datasource": LOKI, "gridPos": gp,
            "targets": targets,
            "options": {"showTime": True, "wrapLogMessage": True, "sortOrder": "Descending", "enableLogDetails": True,
                        "dedupStrategy": "none", "prettifyLogMessage": False, "showLabels": False}}

def loki(expr, legend="", ref="A", instant=False, qtype="range"):
    t = {"datasource": LOKI, "expr": expr, "legendFormat": legend, "refId": ref, "queryType": "instant" if instant else qtype}
    return t

def container_table(gp, sel):
    by = f"by (name, {PROJ})"
    targets = [
        prom(f"sum {by} (rate(container_cpu_usage_seconds_total{{{sel}}}[5m])) * 100", ref="A", instant=True, fmt="table"),
        prom(f"sum {by} (container_memory_working_set_bytes{{{sel}}})", ref="B", instant=True, fmt="table"),
        # node-exporter uses the host network namespace, so its counters are the host's: excluded
        prom(f'sum {by} (rate(container_network_receive_bytes_total{{{sel},name!="node-exporter"}}[5m]))', ref="C", instant=True, fmt="table"),
        prom(f'sum {by} (rate(container_network_transmit_bytes_total{{{sel},name!="node-exporter"}}[5m]))', ref="D", instant=True, fmt="table"),
        prom(f"max {by} (time() - container_start_time_seconds{{{sel}}})", ref="E", instant=True, fmt="table"),
    ]
    units = {"CPU (% of 1 core)": "percent", "Memory": "bytes", "Net in": "Bps", "Net out": "Bps", "Up for": "s"}
    return {"type": "table", "id": nid(), "title": "Containers", "datasource": PROM, "gridPos": gp, "targets": targets,
            "description": "Current usage per running container. CPU is a percentage of one core (the host has 4).",
            "transformations": [
                {"id": "merge", "options": {}},
                {"id": "organize", "options": {
                    "excludeByName": {"Time": True},
                    "indexByName": {"name": 0, PROJ: 1, "Value #A": 2, "Value #B": 3, "Value #C": 4, "Value #D": 5, "Value #E": 6},
                    "renameByName": {"name": "Container", PROJ: "Project", "Value #A": "CPU (% of 1 core)",
                                     "Value #B": "Memory", "Value #C": "Net in", "Value #D": "Net out", "Value #E": "Up for"}}},
                {"id": "sortBy", "options": {"sort": [{"field": "CPU (% of 1 core)", "desc": True}]}},
            ],
            "fieldConfig": {"defaults": {"custom": {"align": "auto", "cellOptions": {"type": "auto"}}},
                            "overrides": [{"matcher": {"id": "byName", "options": n},
                                           "properties": [{"id": "unit", "value": u}, {"id": "decimals", "value": 1 if u == "percent" else None}]}
                                          for n, u in units.items()] +
                                         [{"matcher": {"id": "byName", "options": "Up for"},
                                           "properties": [{"id": "custom.cellOptions", "value": {"type": "color-text"}},
                                                          {"id": "color", "value": {"mode": "thresholds"}},
                                                          {"id": "thresholds", "value": thresholds((None, WARN), (3600, "text"))}]}]},
            "options": {"showHeader": True, "cellHeight": "sm", "footer": {"show": False},
                        "sortBy": [{"displayName": "CPU (% of 1 core)", "desc": True}]}}

ERR_RE = r'(?i)(\blevel=(error|fatal|crit)|\b(error|fatal|panic|exception)\b|\[(error|err|crit)\])'
JOURNAL_ERR = '{source="journal", level=~"error|err|critical|crit|alert|emergency|emerg"}'

def dashboard(uid, title, panels, templating=None, links=None, refresh="30s", tags=()):
    return {"uid": uid, "title": title, "tags": list(tags), "timezone": "browser", "editable": False,
            "graphTooltip": 1, "refresh": refresh, "schemaVersion": 39, "version": 1,
            "time": {"from": "now-6h", "to": "now"}, "fiscalYearStartMonth": 0, "liveNow": False,
            "templating": {"list": templating or []}, "annotations": {"list": []}, "links": links or [],
            "panels": panels}

LINKS = [
    {"title": "Overview", "type": "link", "url": "/d/oci-overview", "icon": "dashboard", "keepTime": True},
    {"title": "Containers", "type": "link", "url": "/d/oci-containers", "icon": "dashboard", "keepTime": True, "includeVars": False},
    {"title": "Node Exporter Full", "type": "link", "url": "/d/rYdddlPWk", "icon": "dashboard", "keepTime": True},
    {"title": "Logs (Explore)", "type": "link", "url": "/explore", "icon": "doc", "keepTime": True},
]

# ---------------------------------------------------------------- overview
_id[0] = 0
P = []
y = 0
P.append(row("Host", y)); y += 1
W = 4
node = 'job="node"'
P += [
    stat("Uptime", [prom(f"node_time_seconds{{{node}}} - node_boot_time_seconds{{{node}}}")], pos(0, y, W, 4), unit="s", decimals=1),
    stat("CPU busy", [prom(f'100 * (1 - avg(rate(node_cpu_seconds_total{{{node},mode="idle"}}[5m])))')], pos(4, y, W, 4),
         unit="percent", decimals=1, status=STATUS_PCT, graph=True),
    stat("Memory used", [prom(f"100 * (1 - node_memory_MemAvailable_bytes{{{node}}} / node_memory_MemTotal_bytes{{{node}}})")],
         pos(8, y, W, 4), unit="percent", decimals=1, status=STATUS_PCT, graph=True),
    stat("Root disk used", [prom(f'100 * (1 - node_filesystem_avail_bytes{{{node},mountpoint="/"}} / node_filesystem_size_bytes{{{node},mountpoint="/"}})')],
         pos(12, y, W, 4), unit="percent", decimals=1, status=STATUS_PCT),
    stat("Running containers", [prom('count(count by (name) (container_last_seen{name!=""}))')], pos(16, y, W, 4)),
    stat("Scrape targets down", [prom("count(up == 0) or vector(0)")], pos(20, y, W, 4),
         status=thresholds((None, GOOD), (1, CRIT)), desc="Prometheus scrape targets currently failing. Details in the Target health panel."),
]
y += 4
P += [
    ts("CPU by mode", [prom(f'sum by (mode) (rate(node_cpu_seconds_total{{{node},mode!="idle"}}[$__rate_interval])) / scalar(count(count by (cpu) (node_cpu_seconds_total{{{node}}})))', "{{mode}}")],
       pos(0, y, 12, 8), "percentunit", stack=True, fill=40, mn=0, mx=1, placement="right", calcs=("mean", "max"),
       desc="Share of total CPU time across all 4 cores. 'steal' is time the OCI hypervisor gave to other tenants."),
    ts("Memory", [
        prom(f"node_memory_MemTotal_bytes{{{node}}} - node_memory_MemAvailable_bytes{{{node}}}", "used", "A"),
        prom(f"node_memory_Buffers_bytes{{{node}}} + node_memory_Cached_bytes{{{node}}}", "cache + buffers", "B"),
        prom(f"node_memory_MemAvailable_bytes{{{node}}} - node_memory_Buffers_bytes{{{node}}} - node_memory_Cached_bytes{{{node}}}", "free", "C"),
    ], pos(12, y, 12, 8), "bytes", stack=True, fill=40, mn=0, placement="right", calcs=("mean", "max", "lastNotNull"),
       desc="Stacks to total RAM. 'cache + buffers' is reclaimable."),
]
y += 8
P += [
    ts("Network (enp0s6)", [
        prom(f"rate(node_network_receive_bytes_total{{{node},{NIC}}}[$__rate_interval])", "in", "A"),
        prom(f"rate(node_network_transmit_bytes_total{{{node},{NIC}}}[$__rate_interval])", "out", "B"),
    ], pos(0, y, 8, 8), "Bps", negative_y="^out$", calcs=("mean", "max"), desc="Public interface. Outbound is drawn below zero."),
    ts("Disk I/O (sda)", [
        prom(f"rate(node_disk_read_bytes_total{{{node},{DISK}}}[$__rate_interval])", "read", "A"),
        prom(f"rate(node_disk_written_bytes_total{{{node},{DISK}}}[$__rate_interval])", "write", "B"),
    ], pos(8, y, 8, 8), "Bps", negative_y="^write$", calcs=("mean", "max"), desc="Writes are drawn below zero."),
    bargauge("Filesystem used", [prom(f'100 * (1 - node_filesystem_avail_bytes{{{node},fstype=~"ext4|xfs|vfat"}} / node_filesystem_size_bytes{{{node},fstype=~"ext4|xfs|vfat"}})', "{{mountpoint}}", instant=True)],
             pos(16, y, 8, 8), "percent", status=STATUS_PCT, mx=100),
]
y += 8
P.append(ts("Target health", [prom("up", "{{job}}")], pos(0, y, 24, 5), "none", legend="list", calcs=()))
P[-1].update(type="state-timeline")
P[-1]["fieldConfig"]["defaults"] = {
    "color": {"mode": "thresholds"}, "thresholds": thresholds((None, CRIT), (1, GOOD)),
    "mappings": [{"type": "value", "options": {"0": {"text": "down", "color": CRIT}, "1": {"text": "up", "color": GOOD}}}],
    "custom": {"lineWidth": 0, "fillOpacity": 80}}
P[-1]["options"] = {"showValue": "never", "mergeValues": True, "rowHeight": 0.8, "alignValue": "left",
                    "legend": {"showLegend": False}, "tooltip": {"mode": "single"}}
y += 5

P.append(row("Containers", y)); y += 1
P.append(container_table(pos(0, y, 24, 10), 'name!=""')); y += 10
P += [
    ts("CPU by project", [prom(f'sum by ({PROJ}) (rate(container_cpu_usage_seconds_total{{name!=""}}[$__rate_interval]))', "{{%s}}" % PROJ)],
       pos(0, y, 12, 9), "short", overrides=project_color_overrides(), placement="right", calcs=("mean", "max"),
       desc="CPU cores used, summed per compose project. See the Containers dashboard for per-container detail."),
    ts("Memory by project", [prom(f'sum by ({PROJ}) (container_memory_working_set_bytes{{name!=""}})', "{{%s}}" % PROJ)],
       pos(12, y, 12, 9), "bytes", overrides=project_color_overrides(), placement="right", calcs=("mean", "max", "lastNotNull"),
       desc="Working set per compose project."),
]
y += 9

P.append(row("Logs", y)); y += 1
P += [
    ts("Error lines per minute", [
        loki(f'sum(count_over_time({{source="docker"}} |~ `{ERR_RE}` [1m]))', "containers", "A"),
    ], pos(0, y, 12, 7), "short", single=True, draw="bars", ds=LOKI,
       desc="Container log lines matching error/fatal/panic/exception. A heuristic: some apps log benign lines containing 'error'."),
    bargauge("Error lines by container (time range)", [
        loki(f'sort_desc(sum by (container) (count_over_time({{source="docker"}} |~ `{ERR_RE}` [$__range])))', "{{container}}", instant=True),
    ], pos(12, y, 12, 7), "short", ds=LOKI),
]
y += 7
P.append(logs("Recent errors (containers + host journal)", [
    loki(f'{{source="docker"}} |~ `{ERR_RE}`', ref="A"),
    loki(JOURNAL_ERR, ref="B"),
], pos(0, y, 24, 12)))

overview = dashboard("oci-overview", "OCI Host - Overview", P, links=LINKS[1:], tags=("oci",))

# ---------------------------------------------------------------- containers
_id[0] = 0
var = [
    {"name": "project", "label": "Project", "type": "query", "datasource": PROM, "refresh": 2, "sort": 1,
     "query": {"query": f'label_values(container_last_seen{{name!=""}}, {PROJ})', "refId": "project"},
     "definition": f'label_values(container_last_seen{{name!=""}}, {PROJ})',
     "multi": True, "includeAll": True, "current": {"text": "All", "value": "$__all"}},
    {"name": "container", "label": "Container", "type": "query", "datasource": PROM, "refresh": 2, "sort": 1,
     "query": {"query": f'label_values(container_last_seen{{{PROJ}=~"$project", name!=""}}, name)', "refId": "container"},
     "definition": f'label_values(container_last_seen{{{PROJ}=~"$project", name!=""}}, name)',
     "multi": True, "includeAll": True, "current": {"text": "All", "value": "$__all"}},
]
SEL = f'name=~"$container", {PROJ}=~"$project", name!=""'
C = []
y = 0
C.append(container_table(pos(0, y, 24, 9), SEL)); y += 9
C += [
    ts("CPU", [prom(f"sum by (name) (rate(container_cpu_usage_seconds_total{{{SEL}}}[$__rate_interval]))", "{{name}}")],
       pos(0, y, 12, 9), "short", placement="right", calcs=("mean", "max"), desc="CPU cores used."),
    ts("Memory (working set)", [prom(f"sum by (name) (container_memory_working_set_bytes{{{SEL}}})", "{{name}}")],
       pos(12, y, 12, 9), "bytes", placement="right", calcs=("mean", "max", "lastNotNull")),
]
y += 9
C += [
    ts("Network in", [prom(f'sum by (name) (rate(container_network_receive_bytes_total{{{SEL},name!="node-exporter"}}[$__rate_interval]))', "{{name}}")],
       pos(0, y, 12, 8), "Bps", placement="right", calcs=("mean", "max")),
    ts("Network out", [prom(f'sum by (name) (rate(container_network_transmit_bytes_total{{{SEL},name!="node-exporter"}}[$__rate_interval]))', "{{name}}")],
       pos(12, y, 12, 8), "Bps", placement="right", calcs=("mean", "max")),
]
y += 8
C += [
    ts("Disk read", [prom(f"sum by (name) (rate(container_fs_reads_bytes_total{{{SEL}}}[$__rate_interval]))", "{{name}}")],
       pos(0, y, 12, 8), "Bps", placement="right", calcs=("mean", "max")),
    ts("Disk write", [prom(f"sum by (name) (rate(container_fs_writes_bytes_total{{{SEL}}}[$__rate_interval]))", "{{name}}")],
       pos(12, y, 12, 8), "Bps", placement="right", calcs=("mean", "max")),
]
y += 8
C.append(ts("OOM kills", [prom(f"sum by (name) (increase(container_oom_events_total{{{SEL}}}[$__rate_interval])) > 0", "{{name}}")],
            pos(0, y, 24, 5), "short", draw="bars", calcs=("sum",), legend="list",
            desc="Out-of-memory kills inside a container. Empty is good."))
y += 5
C.append(logs("Logs", [loki('{source="docker", container=~"$container", compose_project=~"$project"}')], pos(0, y, 24, 14)))

containers = dashboard("oci-containers", "OCI Host - Containers", C, templating=var, links=[LINKS[0], LINKS[2], LINKS[3]], tags=("oci",))

os.makedirs(OUT, exist_ok=True)
for name, d in (("overview.json", overview), ("containers.json", containers)):
    with open(os.path.join(OUT, name), "w") as f:
        json.dump(d, f, indent=2)
        f.write("\n")
print("wrote", OUT)
