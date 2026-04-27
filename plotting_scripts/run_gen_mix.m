mix_fwd_dir={'run_val_coul_tc_gentim_g00S_mix_last_50_n', ...
             'run_val_coul_tc_gentim_g00SNV_mix_last_50_n_.05e5_.2e5_.003',...
             'run_val_coul_tc_gentim_g00S_mix_last_50_n_.05e5_.2e5_0.00075'};

%strapp =  {'','_.05e5_.2e5_.001','_.05e5_.2e5_.002'};
savename = {'base','SNV_03'};

for i=2;
	%mix_fwd_dir = [mix_fwd_dir_base strapp{i}];
	gen_streamice_issm_output_temp2(mix_fwd_dir{i});
	eval(['!cp -r TransientCalMix TransientCalMix_' savename{i}]);
	eval(['!cp comparison.mat comparison_' savename{i} '_.mat']);
end
