module.exports = {
    elements: {
        payslipForm: by.name('payslipForm'),
        employeeName: by.css('form h4'),
        annualIncome: by.xpath('//td[contains(text(), "Annual Income")]/following-sibling::td'),
        super: by.xpath('//td[contains(text(), "Super")]/following-sibling::td'),
        paymentlist: by.xpath('//div[@class="payment-list well"]'),
        employeetablename: by.xpath('//div[@class="payment-list well"]/descendant::div[contains(text(),"John Snow")]'),
        payslipheader: by.xpath('//h2[contains(text(),"Payslip")]'),
        employeeinfo: by.xpath('//h2[contains(text(),"Employee Info")]'),
    },
};