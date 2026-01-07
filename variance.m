subplot(211)
x=load('QTR_LOR'); k=find(abs(x-median(x))<1e-4); x=x(k);
plot(x-x(1))
hold on
subplot(212)
[sig,sig2,osig,msig,tsig,tau]=avar(x,600);loglog(tau,msig)
hold on
x=load('NUR_DCF'); k=find(abs(x-median(x))<1e-4); x=x(k);
subplot(211)
plot(x-x(1))
subplot(212)
[sig,sig2,osig,msig,tsig,tau]=avar(x,600);loglog(tau,msig)
x=load('MUN_DCF'); k=find(abs(x-median(x))<1e-4); x=x(k);
subplot(211)
plot(x-x(1))
subplot(212)
[sig,sig2,osig,msig,tsig,tau]=avar(x,600);loglog(tau,msig)
x=load('FR_ALS'); k=find(abs(x-median(x))<1e-4); x=x(k);
subplot(211)
plot(x-x(1))
subplot(212)
[sig,sig2,osig,msig,tsig,tau]=avar(x,600);loglog(tau,msig)
x=load('ECH_ALS'); k=find(abs(x-median(x))<1e-4); x=x(k);
subplot(211)
plot(x-x(1))
subplot(212)
[sig,sig2,osig,msig,tsig,tau]=avar(x,600);loglog(tau,msig)
xlabel('tau (s)')
ylabel('MDEV (no unit)')
grid on
legend('LORAN QTR','DCF NUR','DCF MUN','ALS FR','ALS EIS')
