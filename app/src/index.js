import Web3 from "web3";
import contract from "truffle-contract";
import "./style.css";
import $ from "jquery";

import tictactoe_artifacts from "../../build/contracts/TicTacToe.json";

var TicTacToe = contract(tictactoe_artifacts);
var tictactoeinstance;
var account;
var accounts;

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function() {
    const { web3 } = this;

    TicTacToe.setProvider(web3.currentProvider);

    await web3.eth.getAccounts(function(err,accs){
      if(err!=null){
        alert("There was an error fetching your accounts.");
        return;
      }

      if(accs.length==0){
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      }

      accounts = accs;
      account = accounts[0];
      console.log(account);
    });

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = metaCoinArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        metaCoinArtifact.abi,
        deployedNetwork.address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }

  },

  createNewGame: function(){
    TicTacToe.new({from: account, value: Web3.utils.toWei('0.1', 'ether'), gas:3000000}).then(instance=>{
      tictactoeinstance = instance;

    for(var i=0;i<3;i++) {
      for(var j=0;j<3;j++) {
        $($("#board")[0].children[0].children[i].children[j]).off('click').click({x:i, y:j}, App.setStone);
      }
    }

      console.log(instance);
    }).catch(error=>{
      console.log(error);
    })
  },

  joinGame: function(){
    var gameAddress = prompt("Address of the game");
    if (gameAddress != null) {
      TicTacToe.at(gameAddress).then(instance => {
        tictactoeinstance = instance;
        return tictactoeinstance.joinGame({from: account, value: Web3.utils.toWei('0.1', 'ether'), gas:3000000}).then(txResult => {
          console.log(txResult);
        })
      })
    }
    console.log("Join Game Called.");

    for(var i=0;i<3;i++) {
      for(var j=0;j<3;j++) {
        $($("#board")[0].children[0].children[i].children[j]).off('click').click({x:i, y:j}, App.setStone);
      }
    }
  },

  useAccountOne: function(){
    account = accounts[1];
  },

  setStone: function(event) {
    console.log(event);
    tictactoeinstance.setStone(event.data.x, event.data.y, {from:account}).then(txResult => {
      App.printBoard();
    })
  },

  printBoard: function() {
    tictactoeinstance.getBoard.call().then(board => {
      for (var i=0; i<board.length; i++) {
        for (var j=0; j<board.length; j++) {
          if (board[i][j] == account) {
            $("#board")[0].children[0].children[i].children[j].innerHTML = "X";
          } else if (board[i][j] != 0) {
            $("#board")[0].children[0].children[i].children[j].innerHTML = "0";
          }
        }
      }
    })
  }

};

window.App = App;

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    );
  }

  App.start();
});
