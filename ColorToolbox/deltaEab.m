function DEab = deltaEab(Lab1, Lab2)
%                    L1* - L2*                   a1* - a2*                   b1* - b2*
DEab = sqrt(  (Lab1(1, :)-Lab2(1,:)).^2  +  (Lab1(2,:)-Lab2(2,:)).^2  +  (Lab1(3,:)-Lab2(3,:)).^2  );
end