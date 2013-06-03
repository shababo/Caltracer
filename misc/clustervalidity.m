function result = clustervalidity(result,data,param)
%modified validation function for clustering, it calculates all the
%validity measures, so param.val is not needed

% Setup some data and parameters.
N = size(result.data.f,1);
c = size(result.cluster.v,1);
n = size(result.cluster.v,2);
v = result.cluster.v;

%for identification of compact and well separated clusters
[m,label] = min(result.data.d');%crisp clustering(Kmeans)
[m2,label2] = max(result.data.f');
for i = 1:c
     index = find(label2 == i);
     dat{i} = data.X(index,:);
     meret(i) = size(dat{i},1);
     centr{i} = result.cluster.v(i,:);
     if isfield(result.cluster, 'P')
	 covmat{i} = result.cluster.P(:,:,i);
     else
	 covmat{i} = eye(n);
     end
end

if exist('param.m')==1
    m = param.m;
else 
    m = 2;
end

%partition coefficient (PC)
fm = (result.data.f).^m;
PC = 1/N*sum(sum(fm));

%classification entropy (CE)
fm = (result.data.f).*log(result.data.f+eps);
CE = -1/N*sum(sum(fm));
     
%results   
result.validity.PC = PC;
result.validity.CE = CE;                          

%partition index(SC)
ni = sum(result.data.f);                        %calculate fuzzy cardinality
si = sum(result.data.d.*result.data.f.^(m/2));  %calculate fuzzy variation
pii=si./ni;
mask = zeros(c,n,c);                            %calculate separation of clusters 
for i = 1:c
    for j =1:c
         mask(j,:,i) = v(i,:);
    end
    dist(i) = sum(sum((mask(:,:,i) - v).^2));
end
s = dist;
SC = sum(pii./s);

%separation index (S)
S = sum(pii)./(N*min(dist));

%Xie and Beni's index (XB)
XB = sum((sum(result.data.d.*result.data.f.^2))./(N*min(result.data.d)));
%results    
result.validity.SC = SC;
result.validity.S = S;
result.validity.XB = XB;    
        

%Dunn's index (DI)

% The minimal distance between clusters, based on the min distances
% between one point in each cluster.
mindistmatrix =ones(c,c)*inf;

% ccidx - current cluster idx.
% ocidx - other cluster idx.
% cpidx - current point idx
for ccidx = 1:c
    cc_size = meret(ccidx);
    for ocidx = (ccidx+1):c
	oc_size = meret(ocidx);
	for cpidx = 1:cc_size
	    point = dat{ccidx}(cpidx,:);
	    % Minimum distance from current point to all other
            % points in the other cluster.
	    dd = min(sqrt(sum([(repmat(point,oc_size,1) - dat{ocidx}).^2]')));
	    
	    if mindistmatrix(ccidx,ocidx) > dd
		mindistmatrix(ccidx,ocidx) = dd;
	    end
	end
    end
end
% The minimial distance between two clusters.
minimalDist = min(min(mindistmatrix));


% Measure the intra cluster distance of points and find the maximum.
maxDispersion = 0;
for ccidx = 1:c
    cc_size = meret(ccidx);
    actualDispersion = 0;
    for cpidx = 1:cc_size
	point = dat{ccidx}(cpidx,:);
	dd = max(sqrt(sum([(repmat(point,cc_size,1) - dat{ccidx}).^2]')));
	if actualDispersion < dd
	    actualDispersion = dd;
	end
	if maxDispersion < actualDispersion
	    maxDispersion = actualDispersion;
	end
    end
end

DI = minimalDist/maxDispersion;

%results
result.validity.DI = DI;


% Add the Davies-Bouldin index.
q = 2;
t = 2;
% Compute the average cluster error.
averageError = 0;
for ccidx = 1:c
    cc_size = meret(ccidx);
    currcentr = centr{ccidx};   
    % Minimum distance from current point to all other points in the
    % other cluster.  We must use the values computed in the routines
    % becaues of special metrics, unless we use the metric matrix
    % here.  A simple distance here will not suffice.
    S(ccidx) = 1/cc_size*sum(result.data.d(index,c));
end
% Compute the center "distances".
distmatrix = zeros(c,c); % zeros are OK since all distances > 0.
DBij = zeros(c,c); % zeros are OK since all distances > 0.
for i = 1:c
    mi = centr{i};
    cov_mati = covmat{i};
    for j = (i+1):c
	cov_matj = covmat{j};
	% So should these distance happen with the norm inducing
        % matrices?  I think so because the distance of one cluster to
        % anther depends on the norm for one of the clusters.  But
        % then the distance isn't symmetric.  Hmm.. -DCS:2005/07/14
	% So this should be equivalent for those that don't have a
        % correlation matrix.
	mj = centr{j};
	dij = mi - mj; 
	dji = mj - mi;			% I know, I know.
	otoc_distij = sqrt(sum(dij*cov_mati.*dij,2));
	otoc_distji = sqrt(sum(dji*cov_matj.*dji,2));
	
	center_dist_avg =1/2*(otoc_distij+otoc_distji+eps);
	DBij(i,j) = (S(i)+S(j))/center_dist_avg;	
	DBij(j,i) = DBij(i,j);
    end
end
DBi = max(DBij);
DB = 1/c*sum(DBi);
result.validity.DB = DB;

% Add the fuzzy hypervolume.
result.validity.FHV = NaN;
FHV = 0;
for i = 1:c
    FHV = FHV + sqrt(abs(det(covmat{i})));
end
result.validity.FHV = FHV;




        
