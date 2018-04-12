{% from "stressng/map.jinja" import exec_stressng as exec_stressng_map with context %}
{% set stressng_path = exec_stressng_map.get('stressng_path','/usr/bin/stress-ng') %}
{% set cli_args = exec_stressng_map.get ('cmd_cli_args','') %}
{% set job_file_list = exec_stressng_map.get ('job_file_list',[]) %}
{% set out_dir = exec_stressng_map.get('out_dir','/tmp/outputdata') %}
{% set test_id = grains.get('testgitref','no_test_id_grain') %}
{% set minion_id = grains.get('host', 'no_hostname_grain' ) %}
check_and_setup:
  cmd.run:
    - name: '{{ stressng_path }} -h'
  file.directory:
    - name: {{ out_dir }}

{% for job_file in job_file_list %}
{% set test_out_dir = [out_dir,job_file] | join('/') %}

run_stressng_jobfile_{{job_file}}:
  file.managed:
    - name: {{ test_out_dir }}/job.stress
    - source: salt://stressng/files/{{ job_file }}
    - requires: 
      - file.directory  
    - makedirs: True

{% set base_cmd_list = [stressng_path, cli_args, '--yaml', [test_out_dir,'/data.yaml']|join('') , '--log-file', [test_out_dir,'/test.log'] | join('')  ] %}  

  cmd.run:
    - name: {{ base_cmd_list | join(' ') }}  --job {{ test_out_dir }}/job.stress
    - requires:
      - check_and_setup
      - file.managed

{% endfor %}



    