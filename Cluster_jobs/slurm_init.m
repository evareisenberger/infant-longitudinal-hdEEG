addpath("/home/ereisenberger/BABY/Toolboxes/plus-slurm-matlab-main")

cfg=[];
cfg.mem= '150G';
cfg.request_time = 900;
%cfg.qos = 'high_prio';

plus_slurm_struct = plus_slurm.create(cfg);

