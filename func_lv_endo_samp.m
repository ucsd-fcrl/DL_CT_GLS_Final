function [samp_points] = func_lv_endo_samp(seg,samp_interv)
%func_lv_endo_samp Takes a segmentation image and samples points of lv endocardium with
%sampling interval samp_interv


seg_lv=seg==1;
seg_perim=bwperim(seg);
seg_lv_perim=bwperim(seg_lv);

stack_perim=seg_perim+seg_lv_perim;
lv_endo_perim=stack_perim==2;


for i=1:size(seg,1)
    if sum(find(lv_endo_perim(i,:)))==0
        lv_endo_perim_index(i,1)=0;
        lv_endo_perim_index(i,2)=0;
    else
        lv_endo_perim_index(i,1)=find(lv_endo_perim(i,:),1);
        lv_endo_perim_index(i,2)=find(lv_endo_perim(i,:),1,'last');
    end
end

% exclude repeated points at the ends
for j=1:2
    for k=1:size(seg,1)-1
        if abs(lv_endo_perim_index(k,j)-lv_endo_perim_index(k+1,j))>5 & abs(lv_endo_perim_index(k,j)-lv_endo_perim_index(k+1,j))<50 & abs(k-find(lv_endo_perim_index(:,j),1))<15
            lv_endo_perim_index(1:k,j)=zeros(k,1);
        end
        if abs(lv_endo_perim_index(k,j)-lv_endo_perim_index(k+1,j))>abs(lv_endo_perim_index(k,j)-lv_endo_perim_index(k+1,3-j)) & abs(k-find(lv_endo_perim_index(:,j),1))<15
            lv_endo_perim_index(1:k,j)=zeros(k,1);
        end
    end
end


samp_start=find(lv_endo_perim_index(:,1));
samp_end=find(lv_endo_perim_index(:,2));
samp_mid=find(sum(lv_endo_perim_index,2),1,'last');

samp_l=[samp_start:samp_interv:samp_mid-2 samp_mid];
samp_r=[samp_end:samp_interv:samp_mid-2];
samp_r=flip(samp_r);

samp_points=[samp_l samp_r;lv_endo_perim_index(samp_l,1)' lv_endo_perim_index(samp_r,2)'];
samp_points=flip(samp_points);

check=samp_points==0;
remove=find(check(1,:));
samp_points(:,remove)=[];

remove2=[];
for m=2:size(samp_points,2)-1
    if abs(samp_points(1,m)-samp_points(1,m-1))>3*abs(samp_points(1,m+1)-samp_points(1,m-1)) & abs(samp_points(1,m)-samp_points(1,m+1))>3*abs(samp_points(1,m+1)-samp_points(1,m-1))
        remove2=[remove2 m];
    end
end
samp_points(:,remove2)=[];

end