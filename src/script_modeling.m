% rmMain([1 3],ROIname,5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain');

%rmMain([1 3],[],5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain');
rmMain([1 6],[],5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain');

rmMain([1 6],'Right_Aud',5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_right_aud');

%cd /home/battal/Documents/AnBa
rmMain([1 6],'left_Auditory',5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_left_aud2');

%AlSa
rmMain([1 7],'left_Auditory',5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_left_aud2');
