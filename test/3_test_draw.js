var TicTacToe = artifacts.require("TicTacToe");

contract("TicTacToe", function(accounts) {
  console.log(accounts);

  it("should be possible to draw 0858711", function(){
    var ticTacToeInstance;
    var playerOne = accounts[0];
    var playerTwo = accounts[1];

    return TicTacToe.new({from: playerOne, value: web3.utils.toWei('0.1','ether')}).then(function(instance){
      ticTacToeInstance = instance;

      return ticTacToeInstance.joinGame({from: playerTwo, value: web3.utils.toWei('0.1','ether')});

    }).then(txResult => {
      return ticTacToeInstance.setStone(0,0, {from: txResult.logs[1].args.NextPlayer_studentID});
    }).then(txResult => {
      // console.log(txResult)
      return ticTacToeInstance.setStone(1,1, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      // console.log(txResult)
      return ticTacToeInstance.setStone(0,1, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      // console.log(txResult)
      return ticTacToeInstance.setStone(0,2, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      // console.log(txResult)
      return ticTacToeInstance.setStone(2,0, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      return ticTacToeInstance.setStone(1,0, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      return ticTacToeInstance.setStone(1,2, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      return ticTacToeInstance.setStone(2,1, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      return ticTacToeInstance.setStone(2,2, {from: txResult.logs[0].args.NextPlayer_studentID});
    }).then(txResult => {
      console.log(txResult)
      assert.equal(txResult.logs[0].event, 'GameOverWithDraw', 'something wrong with draw...')
    }).catch(err => {
      console.log(err);
    })

  })
});
