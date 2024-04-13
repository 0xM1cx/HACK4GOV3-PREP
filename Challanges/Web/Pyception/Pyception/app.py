from flask import Flask, render_template, request, url_for, redirect
import io,sys,random

app = Flask(__name__)

def test(code):
  ls = [" - That's such a nice Quote"," - Absolutely spot on!", " - Couldn't agree more!"," - Brilliantly said!"," - That's pure wisdom!"," - You hit the nail on the head!"," - That's the shitass quote"]
  random_quote = random.choice(ls)
  
  if code[0] == '"' and code[-1] == '"' and all(ch != '"' for ch in code[1:-1]) and code != "":
    try:
        output_stream = io.StringIO()
        compiled = compile('code = print("' + eval(code) + '")', "out", mode = "exec")

        sys.stdout = output_stream
        exec(compiled, globals())
        sys.stdout = sys.__stdout__

        return output_stream.getvalue() + random_quote
    except Exception as e:
        return f":< Do not mess with syntax"

  else:
    return ":< Told you I need input in double quote and double quote inside double quote is not allowed"

@app.route('/', methods=['GET','POST'])
def HomePage():
    te = None
    if request.method == 'POST':
      te = request.form['text']
      return render_template('index.html',output=test(te))
    else:
       return render_template('index.html')

@app.route('/static/flag.txt')
def not_allowed():
    return redirect('/')

@app.route('/app.py')
def not_allowed2():
    return redirect('/')

if __name__ == '__main__':
    app.run(host = "0.0.0.0",port=80, debug=False)