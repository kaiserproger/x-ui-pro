#!/bin/bash
### https://github.com/GFW4Fun
set -euo pipefail
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"
function msg_inf() {  echo -e "${Blue} $1 ${Font}"; }
function msg_ok() { echo -e "${OK} ${Blue} $1 ${Font}"; }
function msg_err() { echo -e "${ERROR} ${Yellow} $1 ${Font}"; }
###################################
apt install unzip -y
cd "$HOME"
if [[ -d "randomfakehtml-master" ]]; then
	cd randomfakehtml-master
else
	wget -q -O master.zip https://github.com/GFW4Fun/randomfakehtml/archive/refs/heads/master.zip
	unzip master.zip && rm master.zip
	cd randomfakehtml-master
	rm -rf assets
	rm ".gitattributes" "README.md" "_config.yml"
fi
###################################
mapfile -t templates < <(for entry in *; do [[ -d "$entry" ]] && echo "$entry"; done)
if [[ ${#templates[@]} -eq 0 ]]; then
	msg_err "No templates found in randomfakehtml-master!"
	exit 1
fi
RandomHTML="${templates[$((RANDOM % ${#templates[@]}))]}"
msg_inf "Random template name: ${RandomHTML}"
#################################
if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
	rm -rf /var/www/html/*
	cp -a "${RandomHTML}"/. "/var/www/html/"
	msg_ok "Template extracted successfully!"
else
	msg_err "Extraction error!"
	exit 1
fi
#################################

enrich_static_site() {
	local index_file="/var/www/html/index.html"
	[[ -f "$index_file" ]] || return 0

	python3 - <<'PY'
import random
import re
from pathlib import Path

index_path = Path("/var/www/html/index.html")
html = index_path.read_text(encoding="utf-8", errors="ignore")

profiles = [
    {
        "title": "EdgeSphere Cloud Platform",
        "description": "Cloud edge routing, zero-trust access, and global performance acceleration for distributed services.",
        "headline": "Enterprise-grade edge and network platform",
        "subline": "Deploy globally in minutes with low-latency routing, resilient connectivity, and policy-driven access.",
        "services": [
            ("Global Edge", "Latency-aware edge routing across 40+ regions."),
            ("Zero Trust Access", "Identity-aware access policies for internal apps."),
            ("Traffic Shield", "Smart filtering and mitigation for L3-L7 attacks.")
        ],
    },
    {
        "title": "NorthGrid Hosting",
        "description": "Managed hosting and secure delivery for business workloads with predictable performance.",
        "headline": "Managed hosting for critical production systems",
        "subline": "Run APIs, web services, and internal tools with strong observability and SRE-backed operations.",
        "services": [
            ("Managed Kubernetes", "Autoscaling clusters with baseline hardening."),
            ("Secure Transit", "TLS lifecycle automation and encrypted interconnect."),
            ("SRE Operations", "24/7 monitoring, incident response, and SLO reviews.")
        ],
    },
    {
        "title": "AstraCDN Services",
        "description": "Content acceleration and application delivery optimized for modern SaaS and media workloads.",
        "headline": "Content delivery built for modern apps",
        "subline": "Accelerate dynamic APIs and static assets with intelligent caching and route optimization.",
        "services": [
            ("Adaptive Caching", "Cache policies tuned by path, status, and headers."),
            ("Smart Routing", "Automatic route steering based on network health."),
            ("Runtime Security", "Bot controls and request anomaly protections.")
        ],
    },
]

profile = random.choice(profiles)
clients = random.randint(1200, 9800)
regions = random.choice([24, 28, 32, 36, 42, 48])
uptime = random.choice(["99.95%", "99.97%", "99.99%"])

meta_block = f"""
<title>{profile['title']} | Infrastructure Services</title>
<meta name="description" content="{profile['description']}">
<meta property="og:title" content="{profile['title']}">
<meta property="og:description" content="{profile['description']}">
<meta property="og:type" content="website">
<meta name="robots" content="index,follow">
"""

if "<head" in html.lower():
    if "<title" not in html.lower():
        html = re.sub(r"(?is)(<head[^>]*>)", r"\\1\n" + meta_block.strip() + "\n", html, count=1)
    else:
        html = re.sub(r"(?is)<title>.*?</title>", f"<title>{profile['title']} | Infrastructure Services</title>", html, count=1)
        if 'name="description"' not in html.lower():
            html = re.sub(r"(?is)(</head>)", f'  <meta name="description" content="{profile["description"]}">\n\\1', html, count=1)

section = f"""
<section id="platform-overview" style="padding:40px 20px;max-width:1100px;margin:0 auto;font-family:Arial,sans-serif;">
  <div style="margin-bottom:24px;">
    <h1 style="font-size:34px;line-height:1.2;margin:0 0 10px 0;">{profile['headline']}</h1>
    <p style="font-size:17px;opacity:0.9;max-width:860px;">{profile['subline']}</p>
  </div>
  <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;margin-bottom:24px;">
    <div style="padding:14px;border:1px solid #d5d5d5;border-radius:10px;"><strong>Uptime</strong><br>{uptime}</div>
    <div style="padding:14px;border:1px solid #d5d5d5;border-radius:10px;"><strong>Active Clients</strong><br>{clients}+</div>
    <div style="padding:14px;border:1px solid #d5d5d5;border-radius:10px;"><strong>Regions</strong><br>{regions}</div>
  </div>
  <h2 style="font-size:24px;margin:0 0 12px 0;">Services</h2>
  <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:14px;">
    {''.join([f'<article style="padding:16px;border:1px solid #d5d5d5;border-radius:10px;"><h3 style="margin:0 0 6px 0;">{name}</h3><p style="margin:0;">{desc}</p></article>' for name, desc in profile['services']])}
  </div>
  <h2 style="font-size:24px;margin:28px 0 12px 0;">Pricing</h2>
  <ul style="margin:0 0 20px 18px;">
    <li>Starter - for dev teams and pilot workloads</li>
    <li>Business - advanced controls and observability</li>
    <li>Enterprise - multi-region architecture and dedicated support</li>
  </ul>
  <h2 style="font-size:24px;margin:0 0 12px 0;">FAQ</h2>
  <p><strong>How fast is onboarding?</strong> Production-ready setup usually takes less than one business day.</p>
  <p><strong>Do you support hybrid environments?</strong> Yes, with policy-based routing between cloud and on-prem resources.</p>
  <h2 style="font-size:24px;margin:20px 0 12px 0;">Contact</h2>
  <p>Email: ops@{profile['title'].split()[0].lower()}.example.com</p>
</section>
"""

if "</body>" in html.lower():
    html = re.sub(r"(?is)</body>", section + "\n</body>", html, count=1)
else:
    html += section

index_path.write_text(html, encoding="utf-8")
PY
}

if enrich_static_site; then
	msg_ok "Static site enriched with tech/corporate content."
else
	msg_err "Enrichment failed, keeping base template only."
fi
