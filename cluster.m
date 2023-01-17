% load keys_file.mat;

load('keys_file','hashed_data_c','MN_key','CH_keys','SBD')


SBd = SBD;
U = CH_keys;
rng('shuffle');

no1 = randperm(2^52,13)+(2^52 -1);
mg_no1= no1(1) * 2^75;
mg_no2= no1(2:13) * 2^75; 

magic_noUb =char(dec2bin(mg_no1)); %CH 128bit 

magic_noSb =char(dec2bin(mg_no2)); %MN 128 bit for each of the cluster generated seperately



%%CH key refreshment

CH_oldKey=cell(12,3);

for i=1:12
    for j=1:3
       CH_oldKey{i,j}= char(dec2bin(U(i,j)));
    end
end


CH_oldKey2=cell(12,3);
mgnumUb = magic_noUb- '0';  %%convert the strings into a matrix of 0/1 integer

for i=1:12
    for j=1:3
      CH_oldKey2{i,j}= char(xor(CH_oldKey{i,j}- '0',mgnumUb)+ '0');  %% kn= M xor Old_key
    end
end

magic_noUbcls = circshift(magic_noUb,4);  %% Magic no Circular shifted by 4 times (R)
mgnumUbcls = magic_noUbcls- '0';

CH_nKey=cell(12,3);
for i=1:12
    for j=1:3
      CH_nKey{i,j}= char(xor(CH_oldKey2{i,j}- '0',mgnumUbcls)+ '0'); % K(new) = kn xor R
    end
end

CH_newKey = cell(12,3);
for i = 1:12
    for j = 1:3  
      str1=sprintf('text2int("%s",2)',CH_nKey{i,j});
      CH_newKey{i,j} = evalin(symengine,str1);
    end
end

CH_refreshed_key = sym(CH_newKey);


[M,N] = size(CH_refreshed_key );
rowIndex = repmat((1:M)',[1 N]); 
[~,randomizedColIndex] = sort(rand(M,N),2);


newLinearIndex = sub2ind([M,N],rowIndex,randomizedColIndex);
B = CH_refreshed_key(newLinearIndex);



for i=1:M
    C(i,1:2) = B(i,1:2);
    hmac_key(i,:) = C(i,1).*C(i,2);
    other_key(i,:) = B(i,3);
end


HMAC_key = hmac_key;
authentication_key = sym(hmac_key); % 256 bit HMAC key for data authentication




for ij=1:M
    ac= C(ij,1).*other_key(ij);
    bc= C(ij,2).*other_key(ij);
    
    prod = (ac.*bc) ;
    %strprod = dec2bin(subs(prod));
     strprod = decimal2binary(prod);
    
    no_of_bits=ceil(length(strprod)/2);
    extract256=extractBetween(string(strprod),1,no_of_bits);

    str1=sprintf('text2int("%s",2)',extract256);

    s_key(ij,:) = evalin(symengine,str1); 
    
end

secret_key = s_key;





%%% ID refreshment for member nodes

MN_oldKey=cell(45,12,12);
temp = cell(45,12,12);

for k=1:12
   mg_no2b(k,:) = dec2bin(mg_no2(k),128) == '1'; 
end
MN_oldKey2=cell(45,12,12);

for f = 1:12
  for i=1:45
    for j=1:12
         temp(i,j,f) =cellstr(dec2bin(SBd{1,f}(i,j))); 
         MN_oldKey{i,j,f} = cell2mat(temp(i,j,f)) == '1';
         MN_oldKey2(i,j,f)= cellstr(char(xor(MN_oldKey{i,j,f},mg_no2b(f))+ '0')); %%% kn= M xor Old_key
    end
  end
end



% MN_oldKey2=cell(45,12,12);
% 
 
% mg_no2b = dec2bin(mg_no2,128) == '1'; 
% MN_oldKey2=cell(45,12,12);
% for jjj = 1:12
%   for ii=1:45
%     for jj=1:12 
%       %MN_oldKey2{1,jjj}= char(xor(MN_oldKey{1,jjj}(ii,jj),mg_no2b)+ '0'); % kn= M xor Old_key
%       MN_oldKey2(ii,jj,jjj)= cellstr(char(xor(MN_oldKey{ii,jj,jjj},mg_no2b)+ '0'));
%     end
%   end
% end

 
for j=1:12
    magic_noSbcls(j,:) = circshift(magic_noSb(j,:),4); %M_No Circular shifted by 4 times (R)
end


MN_nKey=cell(45,12,12);

for jj = 1:12
  for i=1:45
    for j=1:12
        
      MN_nKey{i,j,jj}= char(xor(MN_oldKey2{i,j,jj}- '0',magic_noSbcls(jj,:))+ '0');% K(new) = kn xor R

    end
  end
end


MN_newId = cell(45,12,12);

for jj=1:12
 for i = 1:45
    for j = 1:12  
      str2=sprintf('text2int("%s",2)',cell2mat(MN_nKey(i,j,jj)));
      MN_newId{i,j,jj} = evalin(symengine,str2);
    end
 end
end

MN_refreshed_id = sym(MN_newId);
new_hashed_data = cell(45,12,12);
sbibdd_k = cell(45,12,12);

for sjj= 1:12
 for si = 1:45
    for sj =1:12
        
      sbibd_k(si,sj,sjj) = sym(secret_key(sj))*sym(MN_refreshed_id(si,sj,sjj));
      
    end
 end
end

MN_refreshed_key = sym(sbibd_k);




new_hashed_data  = cell(45,12,12);


%%% DATA  AUTHENTICATION USING HMAC SHA-256 ALGORITHM 
     
 for cl = 1:12
       new_hashed_data(:,:,cl) = cellstr(HMAC(HMAC_key(cl,1),'HI','SHA-256'));
 end
    
    
    
 hashed_data_c = new_hashed_data;


%  assignin('base','MN_refreshed_key',MN_refreshed_key );
%  assignin('base','new_hashed_data',new_hashed_data);
%  assignin('base','CH_refreshed_key',CH_refreshed_key);
save('keys_file','MN_refreshed_key','new_hashed_data','CH_refreshed_key');

