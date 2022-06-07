{% if grains['os_family'] == "RedHat" %}
install_node-exporter_package:
    pkg.installed:
        - name: golang-github-prometheus-node-exporter
{% elif grains['os_family'] == "Debian" %}
install_node-exporter_package:
    pkg.installed:
        - name: prometheus-node-exporter
{% endif %}

/etc/systemd/system/node-exporter.service:
    file.managed:
        - source: salt://{{ slspath }}/resources/node-exporter.service.j2
        - user: root
        - group: root
        - mode: 0644
        - template: jinja

/etc/consul.d/node-exporter.json:
    file.managed:
        - source: salt://{{ slspath }}/resources/node-exporter.json.j2
        - user: root
        - group: root
        - mode: 0644
        - template: jinja
        - makedirs: True
        - context:
            hostname: {{ grains.fqdn }}

node_exporter_service_reload:
    cmd.run:
        - name: systemctl daemon-reload
        - watch:
            - file: /etc/systemd/system/node-exporter.service

consul_agent_reload:
    cmd.run:
        - name: consul reload
        - watch:
            - file: /etc/consul.d/node-exporter.json

run_node_exporter_service:
    service.running:
        - name: node_exporter
        - enable: True

install_iptables:
    pkg.installed:
        - name: iptables
 
node_exporter_firewall_rule:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - dport: 9100
        - protocol: tcp
        - save: True
        - comment: "Allow node_exporter to listen on port 9100"