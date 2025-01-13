function [metric] = evaluate_Measures(gTLst,evtLst)
    N1 = numel(gTLst);
    N2 = numel(evtLst);
    IoUmatrix = zeros(N1,N2);

    for i = 1:N1
        pix = gTLst{i};
        parfor j = 1:N2
            pix2 = evtLst{j};
            nInter = numel(intersect(pix,pix2));
            nUnion = numel(union(pix,pix2));
            IoUmatrix(i,j) = max(IoUmatrix(i,j),nInter/nUnion);
        end
    end

    match = zeros(N1,N2);
%     max(IoUmatrix)
%     for i = 1:N1
    for i = 1:N1
        [maxV,id] = max(IoUmatrix(i,:));
        if maxV>0
            [maxV1,id2] = max(IoUmatrix(:,id));
            if id2==i
                match(i,id) = 1;
            end
        end
    end

%     match = IoUmatrix>thr;
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