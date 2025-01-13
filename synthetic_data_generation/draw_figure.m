%%draw figure
close all;
clear all;
clc;
methods = {'Suite2P','CaImAn','Begonia','AQuA','AQuA2'};
options = {'size','location','prop','size_vs_SNR','location_vs_SNR','prop_vs_SNR'};
id = 4;
option = options{id};
p0 = ['synthetic_unfixed_',option,'_metrics.mat'];
load(p0)

figure;
hold on;
ax = gca;
cols = [119,172,48;237,177,32;126,47,142;217,83,25;0,114,189]/255;
if size(metrics,1) == 1
    % level
    SNRs = [0:2.5:10,15,20];
    for k = 1:size(metrics,3)
        errs = zeros(1,size(metrics,2));
        meanMetric = zeros(1,size(metrics,2));
        for j = 1:size(metrics,2)
            y = zeros(1,size(metrics,4));
            for z = 1:size(metrics,4)
                y(z) = metrics{1,j,k,z}.IoUij;
            end
            meanMetric(j) = mean(y);
            errs(j) = std(y);
        end
        errorbar(SNRs,meanMetric,2*errs,'Linewidth',1.5,'Color',cols(k,:));
    end
    xlabel('SNR (dB)','FontSize', 16);
    ax.XTick = SNRs;
    xlim([-2,22]);
else
    switch id
        case 1
            levels = 1:0.25:2;
            xlabel('Size-change odds','FontSize', 16);
            xlim([0.9,2.1]);
        case 2
            levels = 0:0.2:1;
            xlabel('Location-change odds','FontSize', 16);
            xlim([-0.1,1.1]);
        case 3
            levels = 0:2:10;
            xlabel('Propagation frames','FontSize', 16);
            xlim([-1,11]);
    end


    for k = 1:size(metrics,3)
        errs = zeros(1,size(metrics,1));
        meanMetric = zeros(1,size(metrics,1));
        for j = 1:size(metrics,1)
            y = zeros(1,size(metrics,4));
            for z = 1:size(metrics,4)
                y(z) = metrics{j,1,k,z}.IoUij;
            end
            meanMetric(j) = mean(y);
            errs(j) = std(y);
        end
        errorbar(levels,meanMetric,2*errs,'Linewidth',1.5,'Color',cols(k,:));
    end
%     xlabel('Level','FontSize', 16);
    
    ax.XTick = levels;
end

% legend(methods,'FontSize', 16);
ylabel('wIoU','FontSize', 16);
ylim([0,1]);
ax.FontSize = 16;
ax.YTick = [0 0.2 0.4 0.6 0.8 1];
