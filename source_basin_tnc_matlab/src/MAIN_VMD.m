clc
clear all
close all
fs=4;%sampling frequency
Ts=1/fs;%sampling period
STA=1; %sampling start position
%---------------------------------------------------------
% X = xlsread('..\wind_farm_forecast.xlsx');
% X = X(5665:8640,end);  %3
 X=xlsread('dataset2.xlsx');
 X = X(:,end);  %Y
L=length(X);%
t=(0:L-1)*Ts;%
K = 5;
u = vmd(X,'NumIMFs',K,'PenaltyFactor',2300);

%% TVF-EMD
THRESH_BWR = 0.25;
BSP_ORDER = 26 ;
u = tvf_emd(X, THRESH_BWR, BSP_ORDER); % TVF-EMD
u = u';
save vmd_data u
% u = u';
% figure(1);
% imfn=u;
% n=size(imfn,1);
% subplot(n+1,1,1);
% plot(t,X);
% ylabel('','fontsize',12,'fontname','');
% for n1=1:n
%     subplot(n+1,1,n1+1);
%     plot(t,u(n1,:));%IMF,a(:,n)an,u(n1,:)un1
%     ylabel(['IMF' int2str(n1)]);%int2str(i)i,y
% end
% xlabel('\itt/h','fontsize',12,'fontname','');
% figure
% for i = 1:K
%     Hy(i,:)= abs(hilbert(u(i,:)));
%     subplot(K,1,i);
%     plot(t,u(i,:),'k',t,Hy(i,:),'r');
%     xlabel(''); ylabel('')
%     grid; legend('','');
% end
% title('');
% set(gcf,'color','w');
% %%
% figure('Name','','Color','white');
% nfft=fix(L/2);
% for i = 1:K
%     Hy(i,:)= abs(hilbert(u(i,:)));
%     p=abs(fft(Hy(i,:))); %fft,p,fft---
%     p = p/length(p)*2;
%     p = p(1: fix(length(p)/2));
%     subplot(K,1,i);
%     plot((0:nfft-1)/nfft*fs/2,p)
%     xlim([0.01 0.14]) %,
%     if i ==1
%         title(''); xlabel(''); ylabel('')
%     else
%         xlabel(''); ylabel('')
%     end
% end
% set(gcf,'color','w');
% %%
% figure('Name','','Color','white');
% for i = 1:K
%     p=abs(fft(u(i,:)));
%     subplot(K,1,i);
%     plot((0:L-1)*fs/L,p)
%     xlim([0 fs/2])
%     if i ==1
%         title(''); xlabel(''); ylabel(['IMF' int2str(i)]);%int2str(i)i,y
%     else
%         xlabel('');  ylabel(['IMF' int2str(i)]);%int2str(i)i,y
%     end
% end
% set(gcf,'color','w');
