{% from "stressng/map.jinja" import exec_stressng as exec_stressng_map with context %}
{% set stressng_path = exec_stressng_map.get('stressng_path','/usr/bin/stress-ng') %}
{% set cli_args = exec_stressng_map.get ('cmd_cli_args','') %}
{% set job_file = exec_stressng_map.get ('job_file','') %}
check_if_stressng_available:
  cmd.run:
    - name: '{{ stressng_path }} -h'

run_stressng:
  {% if (job_file != '') %}
  file.managed:
    - name: /tmp/job.stress
    - source: {{ job_file }}

  cmd.run:
    - name: {{ stressng_path }} {{ cli_args}} --job /tmp/job.stress
    - requires:
      - check_if_stressng_available
      - file.managed

  {% else %}
  cmd.run:
    - name: {{ stressng_path }} {{ cli_args}}
    - requires:
      - check_if_stressng_available
 {% endif %}
    