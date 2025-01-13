function visualizeROI(roiLst, H, W)
    red = zeros(H, W);
    green = zeros(H, W);
    blue = zeros(H, W);
    for i = 1: numel(roiLst)
        pix = roiLst{i};
        x = randi(255,[1,3]);
        while (x(1)>0.6*255 && x(2)>0.6*255 && x(3)>0.6*255) || sum(x)<255
            x = randi(255,[1,3]);
        end
        x = x / 255;
        red(pix) = red(pix) + x(1);
        green(pix) = green(pix) + x(2);
        blue(pix) = blue(pix) + x(3);
    end
    bk = red == 0 & green == 0 & blue == 0;
    red(bk) = 0.95;
    green(bk) = 0.95;
    blue(bk) = 0.95;
    
    figure('Position', [100, 100, 500, 500]);
    imshow(cat(3, red, green, blue));
    axis off;
    set(gca,'position',[0 0 1 1],'units','normalized')

end