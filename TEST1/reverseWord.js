const prompt = require("prompt-sync")();

// MAIN CODE
let str = "hello world";
reverseWords(str); // function call

// FUNCTION TO REVERSE A WORD
function reverseWords(str) {
  // empty char array
  let st = [];

  // traverse to string and push into a stack
  for (let i = 0; i < str.length; ++i) {
    if (str[i] != " ") st.unshift(str[i]);
    else {
      // print all stack value after getting space.
      while (st.length != 0) {
        process.stdout.write(st[0]);
        st.shift();
      }
      process.stdout.write(" ");
    }
  }
  while (st.length != 0) {
    process.stdout.write(st[0]);
    st.shift();
  }
}
