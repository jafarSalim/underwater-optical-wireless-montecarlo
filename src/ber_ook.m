function ber = ber_ook(Pr, rate, rx)
%BER_OOK  Bit error rate of on-off keying with an optimum threshold (Gaussian noise).
%   Pr: average received optical power (W). rx: R (A/W), M (APD gain), F
%   (excess noise factor), in (input-referred current noise, A/sqrt(Hz)).
%   '1' carries 2 Pr, '0' carries nothing; bandwidth B = 0.7 x bit rate.
q = 1.602e-19;  B = 0.7 * rate;
i1 = rx.R * rx.M * 2 * Pr;
s1 = sqrt(2*q*rx.R*2*Pr*rx.M^2*rx.F*B + rx.in^2*B);
s0 = sqrt(rx.in^2*B);
Q = i1 ./ (s1 + s0);
ber = 0.5 * erfc(Q / sqrt(2));
end
