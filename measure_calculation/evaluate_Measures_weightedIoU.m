function [metric] = evaluate_Measures_weightedIoU(gTLst,evtLst,data)
    % IOU is set as : w*TP/(w*TP + w*FN + min(w)*FP)

    data(data<0.1) = 0.1;
    

%     data() = data.^2;
    N1 = numel(gTLst);
    N2 = numel(evtLst);

    
    gTWeight = zeros(1,N1);
    for i = 1:N1
        gTWeight(i) = sum(data(gTLst{i}));
    end
    detectionWeight = zeros(1,N2);
    for i = 1:N2
        detectionWeight(i) = sum(data(evtLst{i}));
    end
    IoUmatrix = zeros(N1,N2);
    parfor i = 1:N1
        pix = gTLst{i};
        for j = 1:N2
            pix2 = evtLst{j};
            pixInter = intersect(pix,pix2);
            interWeight = sum(data(pixInter));
            IoUmatrix(i,j) = interWeight/(gTWeight(i) + detectionWeight(j) - interWeight);
        end
    end

    match = zeros(N1,N2);
    for i = 1:N1
        [maxV,id] = max(IoUmatrix(i,:));
        if maxV>0
            [maxV1,id2] = max(IoUmatrix(:,id));
            if id2==i
                match(i,id) = 1;
            end
        end
    end

    TP = sum(match(:));
    FP = sum(sum(match,1) == 0);
    FN = sum(sum(match,2) == 0);
    precision = TP/(TP+FP);
    recall = TP/(TP+FN);
    F1 = 2*TP/(2*TP + FP + FN);
    IoUinTP = mean(IoUmatrix(match>0));
    metric.precision = precision;
    metric.recall = recall;
    metric.F1 = F1;
    metric.IoUinTP = IoUinTP;
    metric.IoUij = (sum(max(IoUmatrix,[],1)) + sum(max(IoUmatrix,[],2)))/(N1+N2);
end