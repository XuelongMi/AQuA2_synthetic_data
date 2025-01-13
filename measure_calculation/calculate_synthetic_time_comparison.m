close all;
clear all;
options = {'size','location','prop','size_vs_SNR','location_vs_SNR','prop_vs_SNR'};
pRoot = 'D:\Research\AQuA2 prepare\Peer methods\synthetic_unfixed_';
option = options{6};
p0 = [pRoot,option,'_multiPatterns\'];
res_AQuA = load([p0,'AQuA_timeCost.mat']);
res_AQuA2 = load([p0,'AQuA2_timeCost.mat']);
disp([mean(res_AQuA2.timeCost),mean(res_AQuA.timeCost),mean(res_AQuA2.timeCost)./mean(res_AQuA.timeCost)])