{% from "stressng/map.jinja" import exec_stressng as exec_stressng_map with context %}
{% set stressng_path = exec_stressng_map.get('stressng_path','/usr/bin/stress-ng') %}
{% set cli_args = exec_stressng_map.get ('cmd_cli_args','') %}
{% set job_file = exec_stressng_map.get ('job_file','') %}
{% set out_dir = exec_stressng_map.get('out_dir','/tmp/outputdata')}
{% set base_cmd_list = [stressng_path, cli_args, '--yaml', {{ [out_dir,'/data.yaml'] | join('') }}, {{ [out_dir,'/test.log'] | join('') }} ] %}
{% set test_id = grains.get('test_id','no_test_id') %}
{% set minion_id = grains.get('minion_id', 'no_minion_id' %)}

check_if_stressng_available:
  cmd.run:
    - name: '{{ stressng_path }} -h'

run_stressng:
  file.directory:
    - name: {{ out_dir }}

  {% if (job_file != '') %}
  file.managed:
    - name: {{ out_dir }}/job.stress
    - source: {{ job_file }}

  cmd.run:
    - name: {{ base_cmd_list | join(' ') }}  --job {{ outdir }}/job.stress
    - requires:
      - check_if_stressng_available
      - file.managed
      - file.directory

  {% else %}
  cmd.run:
    - name: {{ base_cmd_list | join(' ') }}
    - requires:
      - check_if_stressng_available
      - file.directory
  {% endif %}

make_upload_package:
  file.managed:
    - name: {{ out_dir }}/metadata
    - source: salt://stressng/files/metatemplate
    - template: jinja
    - context:
        - test_id: {{ test_id }}
        - minion_id: {{ minion_id }}
        - timestamp: {{ None|strftime("%A %B %d %Y %H:%M") }}
        {% if (job_file != '') %}
        - command_run: {{ base_cmd_list | join(' ') }}  --job {{ outdir }}/job.stress
        {% else %}
        - command_run: {{ base_cmd_list | join(' ') }}
    - requires:
      - run_stressng

  cmd.run:
    - name: tar -cvzf /tmp/{{test_id}}_{{ minion_id }}.tar.gz {{ out_dir }}/
    - requires:
      - file.managed



    