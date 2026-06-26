function [kge,nse,re,r2] = calcansekge(Q1,Qj)
  len=length(Q1);
    lxajmean=mean(Qj);
    lxajstd=std(Qj);
    lxajsum=sum(Qj);
    obqmean=mean(Q1);
    obqstd=std(Q1);
    obqsum=sum(Q1);
    D=(lxajsum-obqsum)/obqsum*100;
    c=0;dc=0;c3=0;
    c = sum((Qj - Q1).^2);
    dc= sum((Q1 - obqsum/len).^2);
    DC=1-c/dc;
    lxajxiangguanxishu=corrcoef(Qj,Q1);
    lxiangguanxishuz=lxajxiangguanxishu(2);%XAJ-L
    lxiangguanxishuzz=lxiangguanxishuz^2;
    a=(lxiangguanxishuz-1)^2+(lxajstd/obqstd-1)^2+(lxajmean/obqmean-1)^2;
    lxajkge=1-sqrt(a);
    kge=lxajkge;
    nse=DC;
    re=D;
    r2=lxiangguanxishuzz;
    disp(['1.KGE:',num2str(kge)])
    disp(['2.NSE:',num2str(nse)])
    disp(['3.re:',num2str(re)])
    disp(['4.r2:',num2str(r2)])
end
