function coefficients = find_coff_nm(coordinates)
    x = sym(coordinates(:,1));
    y = sym(coordinates(:,2));

    n = size(x,1);

    % A*B = C

    A = sym(zeros(n,n));

    for i=1:n
        val = x(i);
        for j=0:n-1
            A(i,j+1) = val^j;
        end
    end
    

    A_adj = sym(adjoint(A));
    A_det = sym(det(A));
    
    
    A_inv = cell(n,n);
    for i=1:n
        for j=1:n
            A_inv{i,j} = RationalNumber(A_adj(i,j),1);
            A_inv{i,j} = divnr(A_inv{i,j},A_det);
        end
    end
    % correctly calculated A_inv
    
    coefficients = cell(1,n);

    for i=1:n
        sum = RationalNumber(0,1);
        for j=1:n
            curr1 = y(j,1); 
            curr2 = A_inv{i,j};
            toAdd = mulnr(curr2,curr1);
            sum = addr(sum,toAdd);
        end
        coefficients{1,i} = sum;
    end
 
    % remember it returns a cell array
end