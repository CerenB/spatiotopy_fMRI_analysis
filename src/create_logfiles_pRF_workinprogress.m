function create_pRF_stimuli_onset

TR= 2.5;
gap = 12.5; 
N = gap/TR;

for run = 1:7
    load(sprintf('AlSa_fMRI_pRF_%d.mat',run));

    
    for k = 1:71 %%       

        stim1 = [(onset(k,1)/TR),rndNum_p(k)];
        stim2 = [(onset(k+1,1)/TR),rndNum_p(k)];
        %for the stim replicate for 2TR = 5s
        %stim = repmat(stim,2,1);
        stim_all(k,:) = stim1;
        stim_all(k+1,:) = stim2;
            
        if k == 24 || k == 48 || k == 72
            
           for i=1:5
            pause = [(k*N+((k/24)-1)*gap)/TR, 0];
            pause(i,:) = [pause(1)+TR,0];
           end
            %for the puase replicate for 5TR = 12.5
            stim_all(k+1:k+N,:) = pause;

        end
    end
    
    save(sprintf('AlSa_pRF_onset_%d.mat',run),'stim_all');
end

end