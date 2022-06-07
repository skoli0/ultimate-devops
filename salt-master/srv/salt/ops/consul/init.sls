add_consul_repo:
    cmd.run:
        - name: yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

install_consul:
    pkg.installed:
        - pkgs:
            - consul

/etc/consul.d/config.json:
    file.managed:
        - source: salt://{{ slspath }}/resources/config.json.j2
        - user: root
        - group: root
        - mode: 0644
        - template: jinja
        - makedirs: True
        - context:
            hostname: {{ grains.fqdn }}

consul_agent_service_reload:
    cmd.run:
        - name: systemctl daemon-reload

run_consul_client_service:
    service.running:
        - name: consul
        - enable: True
