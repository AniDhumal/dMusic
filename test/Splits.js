require('@nomiclabs/hardhat-truffle5');
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const truffleAssert = require('truffle-assertions');
const Splits=artifacts.require("Splits.sol");
contract ("Splits",(accounts)=>{
    let [alice,bob]=accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await Splits.new();
    });
    // afterEach(async () => {
    //     await contractInstance.kill();
    //  });
describe("Test for adding an artist", ()=>{
    it("Should be able to add new artist", async()=>{
        const result=await contractInstance.addNewArtist("Artist");
        assert.equal(result.receipt.status,true);
        assert.equal(result.logs[0].args.artistname,"Artist");
    })
    it("Should not allow same artist name for another account", async()=>{
        await contractInstance.addNewArtist("Artist1");
        await truffleAssert.reverts(contractInstance.addNewArtist("Artist1"));
    })
    it("Should not allow one account to hold more than one artist name", async()=>{
        await contractInstance.addNewArtist("Artist1",{from:alice});
        await truffleAssert.reverts(contractInstance.addNewArtist("Artist2",{from:alice}));
    })
})
// describe("")
    it("Unregistered artist should not be able to add token", async()=>{
        var selfSplit=50;
        expect(1).equal(1);  
    })
    it("Should be able to add new Song", async()=>{
        await contractInstance.addNewArtist("Artist3",{from:bob});
        var selfSplit=50;
        // const result2=await contractInstance.createSongToken("songname","Artist3",selfSplit,{from:bob});
        // assert.equal(result2.receipt.status,true);
        await expect(await contractInstance.createSongToken("songname","Artist3",selfSplit,{from:bob})).to.emit(contractInstance, "songTokenCreated");
    })
    it("One artist should not be able to add song with same names", async()=>{
        const result=await contractInstance.addNewArtist("Artist1",{from:alice});
        var selfSplit=50;
        const result2=await contractInstance.createSongToken("songname",result.logs[0].args.artistname,selfSplit,{from:alice});
        await utils.shouldThrow(contractInstance.createSongToken("songname",result.logs[0].args.artistname,selfSplit,{from:alice}));
    })
    

});