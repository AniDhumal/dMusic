const Splits=artifacts.require("Splits");
contract ("Splits",(accounts)=>{
    let [alice,bob]=accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await Splits.new();
    });
    afterEach(async () => {
        await contractInstance.kill();
     });

    it("Should be able to add new artist", async()=>{
        const result=await contractInstance.addNewArtist("Artist",from[alice]);
        assert.equal(result.receipt.status,true);
        assert.equal(result.logs[0].args.artistname,"Artist");
    })
    it("Should not allow same artist name for another account", async()=>{
        const result=await contractInstance.addNewArtist("Artist1",{from:alice});
        const result2=await contractInstance.addNewArtist("Artist1",{from:bob});
        assert.equal(result.receipt.status,true);
        assert.equal(result2.receipt.status,false);
    })
    it("Unregistered artist should not be able to add token", async()=>{
        var selfSplit=50;
        await utils.shouldThrow(contractInstance.createSongToken("songname","artistname",selfSplit,{from:alice}));
    })
    it("Should be able to add new Song", async()=>{
        const result=await contractInstance.addNewArtist("Artist1",{from:alice});
        var selfSplit=50;
        const result2=await contractInstance.createSongToken("songname",result.logs[0].args.artistname,selfSplit,{from:alice});
        assert.equal(result2.receipt.status,true);
        assert.equal(result2.logs[0].args.songname,"songname");
        assert.equal(result2.logs[0].args.artistname,result.logs[0].args.artistname);
        assert.equal(result2.logs[0].args.tokenId,86806761350380312975367754058103788362278580235689859354386442452340403295653);
    })
    it("One artist should not be able to add song with same names", async()=>{
        const result=await contractInstance.addNewArtist("Artist1",{from:alice});
        var selfSplit=50;
        const result2=await contractInstance.createSongToken("songname",result.logs[0].args.artistname,selfSplit,{from:alice});
        await utils.shouldThrow(contractInstance.createSongToken("songname",result.logs[0].args.artistname,selfSplit,{from:alice}));
    })
    

});