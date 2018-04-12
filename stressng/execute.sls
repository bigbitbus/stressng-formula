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
{% set starttime = salt['cmd.run']('date +%s') %}
{% set test_out_dir = [out_dir,job_file] | join('/') %}

run_stressng_jobfile:
  file.directory:
    - name: {{ test_out_dir }}
    - makedirs: True

  file.managed:
    - name: {{ test_out_dir }}/job.data
    - source: {{ job_file }}
    - requires: 
      - file.directory  

{% set base_cmd_list = [stressng_path, cli_args, '--yaml', [test_out_dir,'/data.yaml']|join('') , '--log-file', [test_out_dir,'/test.log'] | join('')  ] %}  

  cmd.run:
    - name: {{ base_cmd_list | join(' ') }}  --job {{ out_dir }}/job.stress
    - requires:
      - check_and_setup
      - file.directory
      - file.managed

{% set endtime = salt['cmd.run']('date +%s') %}

  file.append:
     - name: {{ test_out_dir }}/job.data
     - text:
       - start_timestamp {{ starttime }}
       - end_timestamp {{ endtime }}
     - requires:
       - cmd.run
       
{% endfor %}
# make_upload_package:
#   file.managed:
#     - name: {{ out_dir }}/metadata
#     - source: salt://stressng/files/metatemplate
#     - template: jinja
#     - context:
#         test_id: {{ test_id }}
#         minion_id: {{ minion_id }}
# #        Put this back once the strftime filter starts working again - broke in Oxygen
#         {# end_time: {{ None | strftime() }} #}
#         {% if (job_file != '') %}
#         command_run: {{ base_cmd_list | join(' ') }}  --job {{ out_dir }}/job.stress
#         {% else %}
#         command_run: {{ base_cmd_list | join(' ') }}
#         {% endif %}
#     - require_anys:
#       - run_stressng_cli_only
#       - run_stressng_jobfile

#  cmd.run:
#    # Once strftime starts working add the timestamp to the archive name, too.
#    - name: tar -cvzf /tmp/{{test_id}}_{{ minion_id }}__strftimebroken.tar.gz .
#    - cwd: {{ out_dir }}
#    - requires:
#      - make_upload_package



    