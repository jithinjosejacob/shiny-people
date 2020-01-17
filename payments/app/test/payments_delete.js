let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../server');
let should = chai.should();


chai.use(chaiHttp);

/*before((done) => {
    db.payments.remove({}, () => {
       done();
    });
});*/

describe('Delete a specific payment', () => {
    before( (done) => {
        let payment = {
            _id:456,
            annualSalary:81900,
            firstName:"Mend",
            grossIncome:6825,
            incomeTax:1521,
            isNew:true,
            lastName:"Snow",
            netIncome:5304,
            pay:4690,
            payPeriod:"2018-05-30T01:00:00.000Z",
            payPeriodFormatted:"30 May 2018",
            payPeriodMonth:"Month of May",
            super:614,
            superRate:9
        }

    chai.request(server)
        .post('/api/payment')
        .send(payment)
        .end(done())
    })
    it('it should delete a specific payment', (done)=>{
        chai.request(server)
        .delete('/api/payment/456')
        .end((err, res) => {
            if (err) {
                throw err;
            }
            res.should.have.status(200);
            res.body.should.be.a("array");
            res.body.length.should.be.eql(0);
            done();
        });
    });
    it('it should fail due to invalid payment id', (done)=>{
        chai.request(server)
        .delete('/api/payments/888')
        .end((err, res) => {
            res.should.have.status(404);
            done();
        });
    });
});