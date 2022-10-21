function [lv_endo_length,lv_endo_perim_img,lv_area]=func_2DLV_perim(seg,flag);
% Script written by Hui on Nov 1st, 2021
% Input is a segmentation image (2 labels: LV ==1 and LA==2)
% Output is the length of the perimeter of the LV
% The mitral valve plane is removed by looking at the LA boundary

seg_lv=seg==1;
seg_la=seg==2;

if flag==0 % no smoothing
    
    lv_area=sum(sum(seg_lv));
    
    seg_perim=bwperim(seg);
    seg_lv_perim=bwperim(seg_lv);
    
    stack_perim=seg_perim+seg_lv_perim;
    lv_endo_perim=stack_perim==2;
    
    lv_endo_perim_img = double(lv_endo_perim);
    lv_endo_length=sum(lv_endo_perim(:));
    
elseif flag==1 % smoothing & closing holes w/ imclose
        
    se=strel('disk',10);
    %close_seg=imclose(seg,se);
    close_seg_lv=imclose(seg_lv,se);
    close_seg_la=imclose(seg_la,se);
    
    close_seg_lv=bwconvhull(seg_lv);
    close_seg_lv(close_seg_la==1)=0;
    
    lv_area=sum(sum(close_seg_lv));
    
    close_seg=close_seg_lv+close_seg_la;
    
    seg_perim=bwperim(close_seg);
    seg_lv_perim=bwperim(close_seg_lv);
    
    stack_perim=seg_perim+seg_lv_perim;
    lv_endo_perim=stack_perim==2;
    
    lv_endo_perim_img = double(lv_endo_perim);
    lv_endo_length=sum(lv_endo_perim(:));
    
elseif flag==2 %smoothing w/ cscvn
    
    % first smoothing w/ imclose
    se=strel('disk',10);
    close_seg_lv=imclose(seg_lv,se);
    close_seg_la=imclose(seg_la,se);
    
    close_seg_lv=bwconvhull(seg_lv);
    close_seg_lv(close_seg_la==1)=0;
    
    close_seg=close_seg_lv+close_seg_la*2;
    seg=double(close_seg);
    
    samp_interv=5;
    samp_points=func_lv_endo_samp(seg,samp_interv);
    curve=cscvn(samp_points);
    figure(1000)
    fnplt(curve)
    axis ij
    axis([0 size(seg,2) 0 size(seg,1)])
    F = getframe(gca);
    lv_endo_perim=F.cdata;
    lv_endo_perim=lv_endo_perim(:,:,3)-lv_endo_perim(:,:,1);
    lv_endo_perim=lv_endo_perim>0;
    
    %figure;colormap gray
    %imagesc(lv_endo_perim)
    
    lv_endo_perim_img=imresize(lv_endo_perim,size(seg));
    lv_endo_perim_img=double(lv_endo_perim_img);
    
    %figure;colormap gray
    %imagesc(lv_endo_perim_img)
    
    lv_endo_length=sum(lv_endo_perim(:));
    
end
    
end