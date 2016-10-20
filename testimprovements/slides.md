# Test Improvements


## Why

* time consuming to write/maintain tests
  * hard to find things
  * hard to understand (too much noise/LoC)
  * duplicated setup
  * subsystem encapsulation leakage
  * hard to refactor


## Improvements

* Best practices
* Test Data Provider (unit)
* Test Data Provider (integration)



## Best practices

unit tests


## QueryBuilder

How to test this ?

```js
qb.field("Patron.AxiellId", self.CurrentPatron.AxiellId)
  .negate()
  .and("Identity", aCard.Identity);
```


## Suggestion

1. Move the query to a function library.
2. Mock the function library
3. Write an integration test function library


## Example

```
PatronQueries functionlibrary

  FindOtherPatronsWithSameCard action
  ! parameters(patron PatronRef, cardIdentity text)
  ! returnType(PatronRef)
  ! expression ("""
  return qb.field("Patron.AxiellId", args.patron.AxiellId).negate().and("Identity", args.cardIdentity);
 """)
```


## Unit Tests

```js
spyOn(PatronQueries, "FindOtherPatronsWithSameCard")
  .and.returnValue([somePatron]);
```


## Integration Test

```js
describe("FindOtherPatronsWithSameCard", function() {
  describe("when no patron exists with same card", function() {
    setupFixture("Patron/a", ["random_name", "random_card"]);
    setupFixture("Patron/b", ["random_name", "random_card"]);
    it("returns []")
      var result = this.PatronQueries.FindOtherPatronsWithSameCard(
         {patron: this.fixture["Patron/a"]});
      expect(result).toEqual([]);
    })
```


## Another Example

```js
describe("after patron and item ready for renewal have been set but the item has already been renewed today", function() {
  //beforeEach()
  it("should have a FoundItem", function () {});
  it("should say cannot CanCheckout", function () {});
  it("should have a warning message", function () {});
  it("should not say RenewalAllowed", function () {});
  it("should say can force renew", function () {});
  it("should say cannot renew", function () {});
);

describe("...", function() {
  it("should have a FoundItem", function () {});
  it("should say cannot CanCheckout", function () {});
  it("should have a warning message", function () {});
  it("bla bla", function() {});
});
```


## Possible Improvement

```js
function expectRenewalNotAllowed() {
  it("should have a warning message", function() {...});
  it("bla", function() {...});
};

describe("after patron and item ready for renewal have been set but the item has already been renewed today", function() {
  expectRenewalNotAllowed();
  expectForceRenewalAllowed();
  expectWarning("bla bla")
```


## Nested Describes ?

```js
describe("after patron and item ready for renewal have been set" +
"  but the item has already been renewed today", function() {
```

vs.

```js
describe("when patron and item ready for renewal", function() {
  describe("and item has already been renewed today")
})
```


## Describe actions

```js
describe("CirculationProcess", function() {
  describe("the SetActiveAddress action", function() {
    describe("when called with a new reference")
    describe("when ...")
  })  // or just SetActiveAddress ?
})
```


## beforeEach

Should setup what the describe says

```js
describe("when a patron with valid card scans her card", function() {
  beforeEach(function() {
    var patron = tdp.createPatron("patron_with_valid_card");
    this.process.scan(patron.Cards[0].Identity);
  }
  it("...");
  describe("and an item which already has been renewed is scanned", function() {
    beforeEach(function() {
      var item = tdp.createItem("already_renewed_item");
      this.process.scan(item.Barcode);
    });

    expectRenewalNotAllowed();
    expectForceRenewalAllowed();
  })   

```


## Reduce boilerplate

Define fixture and expectation

```js
var testData = [
  { contentType: "txt", mediaTypes: ["n"],  expectedResult: ["book"] },
  { contentType: "txt", mediaTypes: ["n", "n"], expectedResult: ["book"] }
```

Generating Tests:

```js
testData.forEach(function(expression) {
  var language = expression.language,
      contentType = expression.contentType,
      mediaTypes = expression.mediaTypes;

  describe("with contentType: " + contentType + ", mediaTypes: " + mediaTypes.join(", "), function() {
```


## Comparing Objects

Use `objectContaining`

```js
  it("sets all the fields of the payment details", function() {
    expect(this.detail).toEqual(jasmine.objectContaining({
      LastPayment: 1.5,
      IssuedByName: "Test User", // ...
                                                         }));
  });
```


## Disadvantage

Jasmine does not highlight the difference if the test fails. Example

```
  Message:
     Expected LastPaymentDetail{IssuedById=(IssuedById), IssuedByName=(Test User), IssuedAt=(somewhere:there), LastPayment=(1.5), Cancelled=(false), LastPaymentDate=(2015-02-10)} to equal <jasmine.objectContaining(Object({ LastPayment: 1.5, IssuedByName: 'Test User2222' }))>.
   Stacktrace:
     Error: Expected LastPaymentDetail{IssuedById=(IssuedById), IssuedByName=(Test User), IssuedAt=(somewhere:there), LastPayment=(1.5), Cancelled=(false), LastPaymentDate=(2015-02-10)} to equal <jasmine.objectContaining(Object({ LastPayment: 1.5, IssuedByName: 'Test User2222' }))>.
     	at <anonymous> (/dsltest/config/spec/patron/standard/patronDebtSpec.js:105)
     	at <program> (<eval>:1)
```


## Comparing Arrays

```
it("has two items", function() {expect(this.baaz.length).toEqual(2)});
it("first item is foo", function() {...});
it("second item is bar", function() {...});
```

Better:

```
// or expect(this.baaz.map(function(b) {return b.Name}))
it("has foo and bar", function() {
  expect(this.baaz).toEqual(['foo', 'bar']);
})
```


## not.toBe(null)

We have lots of tests that checks that something is not null.

```js
it("should initially have an an AxiellId", function () {
  expect(instance.AxiellId).not.toBe(null);
});
```

Use `expect(instance.AxiellId).toEqual(jasmine.any(String));`


## Mocking

* Only possible to mock actions in function libraries

* Avoid checking low-level things like:
```
spyOn(foo, 'setBar');
expect(foo.setBar.calls.argsFor(0)).toEqual([123]);
```


## Organization of test files

and naming


## Based on the thing being tested

Example: `patronProcess` => `patronProcessSpec.js`


## Based on behaviour
  * `circPatronCheck` - tests everything related to patron scanning his card
  * `circItemCheck` - tests things related to scanning an item
  * `circPatronItemCheckProcess` - tests when both a patron and item has been scanned
  * `circResIssueSpec` - tests when a reserved item has been scanned
  * `circTrappingSpec` - tests checkin and trapping of items


## Suggestion

```
// Let say `MneumonicSearchProcess` been renamed to `circulationProcess`
spec/circulation/standard/reserveProcessSpec.js
spec/circulation/standard/circulationProcess/scanPatronSpec.js
spec/circulation/standard/circulationProcess/scanItemSpec.js
spec/circulation/standard/circulationProcess/scanPatronAndItemSpec.js
spec/circulation/standard/circulationProcess/scanReseveredItemSpec.js
spec/circulation/standard/circulationProcess/checkinReseveredItemSpec.js
spec/circulation/standard/circulationProcess/checkoutSpec.js
spec/circulation/standard/circulationProcess/checkinSpec.js
```



## Test Data Provider

Unit tests


## Why a new TDP ?

* No support for reuse of integration tests
* Complex, e.g 230 loc for `createPatron`
* Duplicated setup, two `createPatron` (circulation/patron)
* Noise/Reuse, (e.g. setup a patron with two cards is needed at many places)
* Subsystem Encapsulation Leakage
* Very difficult to mock QueryBuilder


## Simple Fixture

configFixture.json:
```json
{
  "PatronGender": {
     "female": { "Gender": "Female"}
  },
  "Organization": {
     "C1": { "Code": "C1"},
     "A1": { "Code": "A1", "Parent": "$Organization/C1"}
  }
}
```

```js
tdp.loadFixture("config", "configFixture.json");
var orgC1 = tdp.build("Organization/C1");
```


```json
{ "PatronAccount": {
     "active100Phone": {
        "Authority": "$config/Organization/A1",  "ActivePhone": "Ref100"
     }
  },
  "Phone": {
    "100": { "Number": "100", "Reference": "Ref100" }
  },
  "Patron": {
    "two_phones": {
       "Name": "$PersonName/lotta",
       "Gender": "$config/PatronGender/female",
       "Phones": ["$Phone/100", "$Phone/200"],
       "PatronAccount": "$PatronAccount/active100Phone"
    }
  },
  "PersonName": {
    "kalle": {  "FirstName": "Kalle"  }
  }
}
```


## reuse

```
tdp.build("Patron", ["two_phones", "one_card"])
```


## Programmatic API

```js
tdp.loadFixture(...) // load some fixture we can reuse, e.g. PatronGender
var account = tdp.build("PatronAccount", {ActivePhone: "Ref200"});
tdp.build("Patron/two_phones", {
  Name: { FirstName: "sune"},
  PatronAccount: account,
  Gender: "$config/PatronGender/female"
};
```



# Integration Tests

Use the same Test Data Provider as for unit tests


## Setup, alternative 1

```js
// Create a new patron defined by the myPatron fixture unless it already exists
// wait until it is saved
beforeEach(function(done) {
  var self = this;
  tdp.create("Patron/two_phones").then(function(patron) {
    self.patron = patron;
    done();
  });
});
```


## Alternative 2

```js
describe("something", function() {
  setupFixture("Patron/two_phones");

  it("...", function() {
    var patron = this.fixtures["Patron/two_phones"];
  })
});
```


## Random values

```json
{
  "Patron": {
    "random_name": {
       "Name": "$PersonName/random_name"
    }
  },
  "PersonName": {
    "random_name": {  "FirstName": "$randomString"  }
  }
}
```

```js
describe("something", function() {
  setupFixture("Patron", ["two_phones", "random_name"]);
});
```
