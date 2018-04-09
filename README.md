# Stress-ng formula

[Stress-ng](http://kernel.ubuntu.com/~cking/stress-ng/) is a benchmarking tool to exercise multiple computer subsystems such as CPU, memory, IO and networking.

## What this formula offers

* stressng.install - to install stressng (from the OS packages - the default,  or from source if the pillar stress:lookup:install_from_source is set). For example:
```
salt \* state.apply stressng.install pillar='{"stressng":{"lookup": {"install_from_source": True}}}'
```
You can also set the stress-ng version via a lookup pillar 'stressng_source_url'; the stress-ng source archives are [available here].(http://kernel.ubuntu.com/~cking/tarballs/stress-ng/)

* stressng.execute - run stressng, with the ability to specify all cli options via pillar. The list of flags is available in the [stress-ng manual](http://kernel.ubuntu.com/~cking/stress-ng/stress-ng.pdf). It is often practical to run stress-ng by specifying a "job" file; this function is also exposed through the state; in fact the default run (without any pillar data) will use the examplejob.stress file the in stressng/files folder.

The final test_id_minion_id.tar.gz archive of the results is stored in the /tmp folder, here test_id and minion_id are grains set on the tested system. The archive contain 4 files:

* metadata: Meta-data about the test
```
test_id: no_test_id
minion_id: no_minion_id
command_run: /usr/bin/stress-ng --timeout 10s --yaml /tmp/outputdata/data.yaml --log-file /tmp/outputdata/test.log  --job /tmp/outputdata/job.stress
```
~~timestamp: Thursday April 05 2018 04:42~~ is disabled until e Salt Oxygen fixes strftime/jinja2 issue.

* test.log: stress-ng log file
```
stress-ng: info:  [2714] dispatching hogs: 1 matrix
stress-ng: debug: [2714] cache allocate: default cache size: 4096K
stress-ng: debug: [2714] starting stressors
stress-ng: debug: [2714] 1 stressor spawned
stress-ng: debug: [2715] stress-ng-matrix: can't set oom_score_adj
stress-ng: debug: [2715] stress-ng-matrix: started [2715] (instance 0)
stress-ng: debug: [2715] stress-ng-matrix using method 'all' (x by y)
stress-ng: debug: [2715] stress-ng-matrix: exited [2715] (instance 0)
stress-ng: debug: [2714] process [2715] terminated
stress-ng: info:  [2714] successful run completed in 10.00s
stress-ng: info:  [2714] stressor       bogo ops real time  usr time  sys time   bogo ops/s   bogo ops/s
stress-ng: info:  [2714]                           (secs)    (secs)    (secs)   (real time) (usr+sys time)
stress-ng: info:  [2714] matrix            47382     10.00      9.96      0.02      4737.96      4747.70
```
* data.yaml, for example
```
---
system-info:
      stress-ng-version: 0.09.23
      run-by: root
      date-yyyy-mm-dd: 2018:04:05
      time-hh-mm-ss: 04:42:21
      epoch-secs: 1522903341
      hostname: min_1
...
metrics:
    - stressor: matrix
      bogo-ops: 47382
      bogo-ops-per-second-usr-sys-time: 4747.695391
      bogo-ops-per-second-real-time: 4737.958375
      wall-clock-time: 10.000510
      user-time: 9.960000
      system-time: 0.020000
```
* job.stress, the job file - for example
```
run sequential
verbose
metrics-brief
matrix 1
verify
temp-path /tmp
timeout 10s
```

Here is an example of a cli pillar setting for the execute state.

``` 
salt \* state.apply stressng.install pillar='{'stressng': {'lookup' : {'install_from_source': True }}}'
```