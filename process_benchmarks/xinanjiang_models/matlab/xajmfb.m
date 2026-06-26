clear;
data=xlsread('xinanjiang_yuan_river_input_data.xls',1);
data1=xlsread('xinanjiang_yuan_river_input_data.xls',2);
QZ=data(:,2);                        %QZ

 % K=0.48293;      %   :0.8~1.2
 % SM=150;     %       :10~30
 % KG=0.1;     %   : 0.01~0.69
 % CG=0.9963;     %   :0.98~0.998
 % CI=0.93582;     %   :0.01~0.9
 % CS=0.6;     % :0.1~0.9
 % WUM=50;
 % WLM=50;
 % WDM=50.6511;
 % C=0.5;
 % B=0.5;
 % EX=1;
 K=0.48226;      %   :0.8~1.2
 SM=150;     %       :10~30
 KG=0.10072;     %   : 0.01~0.69
 CG=0.99719;     %   :0.98~0.998
 CI=0.93443;     %   :0.01~0.9
 CS=0.73417;     % :0.1~0.9
 WUM=106;
 WLM=49.95971;
 WDM=50.6511;
 C=0.27409;
 B=0.71518;
 EX=2;
 L=1;          %     :0~2


E0=data(:,3);                          %E0,
EP=K*E0;
F=data1(:,3);
Fr=data1(:,4);

%U,1 24
U=F/(3.6*1*24);                          %U

WM=WUM+WLM+WDM;FC=2.5;FR0=0.1;PTT=0;%PTT
IM=0.01;KI=0.6-KG;WMM=(1+B)*WM/(1-IM);SMM=(1+EX)*SM;SZ=length(E0);



S1=zeros(SZ,1);S1(1)=0;               %S1;S1
FR=zeros(SZ,1);FR(1)=FR0;                       %FR;FR
EU=zeros(SZ,1);                        %EU
EL=zeros(SZ,1);                        %EL
ED=zeros(SZ,1);                        %ED
E=zeros(SZ,1);                         %E
WU=zeros(SZ,1);WU(1)=0;              %WU
WL=zeros(SZ,1);WL(1)=0;              %WL
WD=zeros(SZ,1);WD(1)=0;               %WD
W=zeros(SZ,1);W(1)=WU(1)+WL(1)+WD(1);  %W
R=zeros(SZ,1);                         %R
RG2=zeros(SZ,1);                         %RG2;RG2
RD2=zeros(SZ,1);                         %RD2;RD2
RS3=zeros(SZ,1);                         %RS3;RS3
RI3=zeros(SZ,1);                         %RI3;RI3
RG3=zeros(SZ,1);                         %RG3;RG3
PE=zeros(SZ,1);                         %PE;PE
QI3=zeros(SZ,1);QI3(1)=0;             %QI3;QI3
QG3=zeros(SZ,1);QG3(1)=0;             %QG3;QG3
Q3=zeros(SZ,1);                         %Q3;Q3
Q=zeros(SZ,1);                          %Q;Q
TTT=zeros(SZ,18);                        %TTT;






%%%%%%%%%%%%%10%%%%%%%%%%%%%
for J=1:12
P=(1-IM)*data(:,J+3);   %P,
RB=IM*data(:,J+3);                %RB
PTT=PTT+sum(data(:,J+3))*Fr(J);

for I=1:SZ


%%%%%%%%%%%%%%%%%%%%%%%%%%
if WU(I)+P(I)>=EP(I)
    EU(I)=EP(I);EL(I)=0;ED(I)=0;
else if WL(I)>=C*WLM
        EU(I)=WU(I)+P(I);EL(I)=(EP(I)-EU(I))*WL(I)/WLM;ED(I)=0;
    else if WL(I)>=C*(EP(I)-(WU(I)+P(I)))
            EU(I)=WU(I)+P(I);EL(I)=C*(EP(I)-EU(I));ED(I)=0;
        else
            EU(I)=WU(I)+P(I);EL(I)=WL(I);ED(I)=C*(EP(I)-EU(I))-EL(I);
        end
    end
end
E(I)=EU(I)+EL(I)+ED(I);PE(I)=P(I)-E(I);
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%
a=WMM*(1-(1-W(I)/WM)^(1/(B+1)));  %a
if PE(I)<=0
    R(I)=0;
else if a+PE(I)<=WMM
    R(I)=PE(I)+W(I)-WM+WM*(1-(PE(I)+a)/WMM)^(B+1);
    else
    R(I)=PE(I)+W(I)-WM;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
WU(I+1)=WU(I)+P(I)-EU(I)-R(I);
WL(I+1)=WL(I)-EL(I);
WD(I+1)=WD(I)-ED(I);
if WU(I+1)>WUM
    WL(I+1)=WL(I)-EL(I)+WU(I+1)-WUM;
    WU(I+1)=WUM;
end
if WL(I+1)>WLM
    WD(I+1)=WD(I)-ED(I)+WL(I+1)-WLM;
    WL(I+1)=WLM;
end
if WD(I+1)>WDM
    WD(I+1)=WDM;
end
W(I+1)=WU(I+1)+WL(I+1)+WD(I+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%FR=R/PE%%%%%%%%%%%%%
if PE(I)==0
    FR(I)=0;
else if R(I)/PE(I)>1
        FR(I)=1;
    else
    FR(I)=R(I)/PE(I);
    end
end
%%%%%%%%%%%%%FR=R/PE%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%
if PE(I)<=FC
    RG2(I)=R(I);RD2(I)=0;
else
    RG2(I)=FC*FR(I);RD2(I)=(PE(I)-FC)*FR(I);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%%%%%%
    if I==1
        AU=SMM*(1-(1-(S1(I)*FR0/FR(I))/SM)^(1/(1+EX)));
        if PE(I)<=0
        RS3(I)=0;RI3(I)=0;RG3(I)=0;S1(I+1)=S1(I)*(1-KI-KG);
        else if PE(I)+AU<SMM
            RS3(I)=FR(I)*(PE(I)+S1(I)*FR0/FR(I)-SM+SM*(1-(PE(I)+AU)/SMM)^(EX+1));
             else
            RS3(I)=FR(I)*(PE(I)+S1(I)*FR0/FR(I)-SM);
             end
        S=S1(I)*FR0/FR(I)+(R(I)-RS3(I))/FR(I);
        RI3(I)=KI*S*FR(I);
        RG3(I)=KG*S*FR(I);
        S1(I+1)=S*(1-KI-KG);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        AU=SMM*(1-(1-(S1(I)*FR(I-1)/FR(I))/SM)^(1/(1+EX)));
        if PE(I)<=0
        RS3(I)=0;RI3(I)=0;RG3(I)=0;S1(I+1)=S1(I)*(1-KI-KG);
         else if PE(I)+AU<SMM
                 RS3(I)=FR(I)*(PE(I)+S1(I)*FR(I-1)/FR(I)-SM+SM*(1-(PE(I)+AU)/SMM)^(EX+1));
              else
                 RS3(I)=FR(I)*(PE(I)+S1(I)*FR(I-1)/FR(I)-SM);
              end
        S=S1(I)*FR(I-1)/FR(I)+(R(I)-RS3(I))/FR(I);
        RI3(I)=KI*S*FR(I);
        RG3(I)=KG*S*FR(I);
        S1(I+1)=S*(1-KI-KG);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%

end


%%%%%%%%%%%%%%%%%%%%%%%%%%

QS3=(RS3+RB)*U(J);                               %QS3
for I=2:SZ
    QI3(I)=CI*QI3(I-1)+(1-CI)*RI3(I)*U(J);%(3)
    QG3(I)=CG*QG3(I-1)+(1-CG)*RG3(I)*U(J);
end
QT3=QS3+QI3+QG3;
if L==2
   Q3(2)=CS*Q3(1);
else
   Q3(2)=CS*Q3(1)+(1-CS)*QT3(2-L);
end
for I=3:SZ
    Q3(I)=CS*Q3(I-1)+(1-CS)*QT3(I-L);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
Q=Q+Q3;            %Q

%%%%%%%%%%%%%%%%%%%%%%%%%%
W(end,:)=[];WU(end,:)=[];WL(end,:)=[];WD(end,:)=[];S1(end,:)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%

TT=[data(:,J+3) EU EL ED E PE WU WL WD W R FR RG2 RD2 RS3 RI3 RG3 S1];%
TTT=TTT+TT*Fr(J);                                          %TTT
%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%

[kge,nse,re,r2] = calcansekge(QZ,Q);
fprintf('\n')
