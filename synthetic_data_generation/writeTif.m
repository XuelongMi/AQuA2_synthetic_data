function writeTif( fName, dat, rescale )
%WRITEIFFSEQ Write image sequence

if ~exist('rescale','var')
    rescale = 0;
end

if rescale
    dat = double(dat);
    dat = uint16(dat/max(dat(:))*65535);
end

if length(size(dat))==2
    imwrite(dat,fName);
end

if length(size(dat))==3    
    imwrite(dat(:,:,1),fName);
    for ii=2:size(dat,3)
        imwrite(dat(:,:,ii),fName,'tiff','writemode','append');
    end
end

if length(size(dat))==4
    imwrite(dat(:,:,:,1),fName);
    for ii=2:size(dat,4)
        imwrite(dat(:,:,:,ii),fName,'tiff','writemode','append');
    end    
end



end

