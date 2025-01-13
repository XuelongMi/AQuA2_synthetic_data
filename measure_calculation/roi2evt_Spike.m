function [evt,z] = roi2evt(F,spikes,roi,HW,zThrPk,zThrRatio)
    % events by thresholding dff
    % different thresholds for peak and boundary
    % input can also be df
    %
    % FIXME: still too ad hoc
    %
    % estimate noise
    T = size(F,2);
    nn = 1;
    evt = cell(0);
    z = [];
    for jj=1:numel(roi)
        curve = F(jj,:);
        noise = sqrt(median((curve(2:end) - curve(1:end-1)).^2)/0.9099);
        curve = curve - min(movmean(curve,20));
        z0 = curve/noise;
        z0x = z0>zThrPk;
        cc0 = bwconncomp(z0x);
        cc0 = cc0.PixelIdxList;
        L0 = bwlabel(z0x);
        roi0 = roi{jj};

        curSpike = spikes(jj,:);
        % remove outlier
        s0 = sqrt(mean(curSpike.^2));
        curSpike0 = curSpike;
        curSpike0(curSpike>max(s0*zThrPk,max(curve)*0.1)) = 0;
        s1 = max(s0/10,sqrt(mean(curSpike0.^2)));
        pSpike = find(curSpike>zThrPk*s1 & islocalmax(curSpike));
        pSpike = pSpike(z0x(pSpike));
        pSpikeSeq = false(1,T);
        pSpikeSeq(pSpike) = true;

        for kk=1:numel(cc0)
            % extract
            t0 = cc0{kk}(1);
            t1 = cc0{kk}(end);

            if sum(pSpikeSeq(t0:t1))==0
                continue;
            end

            pHere = pSpike(pSpike>=t0 & pSpike<=t1);
            gapPoint = [t0];
            for i = 1:numel(pHere)-1
                tPre = pHere(i);
                tCur = pHere(i+1);
                [~,tMin] = min(curve(tPre:tCur));
                gapPoint = [gapPoint,tPre + tMin-1];
            end
            gapPoint = [gapPoint,t1];
            for i = 1:numel(gapPoint)-1
                t00 = gapPoint(i);
                t11 = gapPoint(i+1);

                vox0 = reshape(roi0,[],1)+(reshape(t00:t11,1,[])-1)*HW;
                evt{nn} = vox0(:);
%                 z(nn) = max(z0(t0)); %#ok<AGROW>
                nn = nn + 1;
            end


% 
%             ta = max(min(t0)-10,1);
%             tb = min(max(t0)+10,T);
%             zSel = z0(ta:tb);
%             LSel = L0(ta:tb);
%             zSel(LSel>0 & LSel~=kk) = -1;
%             
%             % find peak and borders
%             [xp,tp] = max(zSel);
%             ta1 = find(zSel(1:tp)<zThrRatio*xp,1,'last');
%             if isempty(ta1)
%                 ta1 = 1;
%             else
%                 ta1 = min(ta1+1,tp);
%             end
%             tb1 = find(zSel(tp:end)<zThrRatio*xp,1);
%             if isempty(tb1)
%                 tb1 = numel(zSel);
%             else
%                 tb1 = max(tb1+tp-1-1,tp);
%             end
%             
%             % new range
%             t1 = (ta+ta1-1):(ta+tb1-1);          
%             vox0 = reshape(roi0,[],1)+(reshape(t1,1,[])-1)*HW;
%             evt{nn} = vox0(:);
%             z(nn) = max(z0(t0)); %#ok<AGROW>
%             nn = nn + 1;
        end
    end    
    
end