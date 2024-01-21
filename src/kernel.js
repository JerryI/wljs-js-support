function __isElement(element) {
    return element instanceof Element || element instanceof HTMLDocument;  
  }
  
class ScopedEval {
  ondestroy = function() {}
  after = function() {}
  error  = false
    
  constructor(scope, script) {
    this.script = '(() => {'+ script + '})()';
  }
    
  eval() {
    try {
      return eval(this.script);
    } catch(err) {
      this.error = err;
    }
  }
} 

class JSCell {
    scope = {}
    createScopedEval = (scope, script) => {return({
      ondestroy: function() {},
      after: function() {},
      result: Function(`${script}`)
    })}  
    
    dispose() {
      this.scope.ondestroy();
    }
    
    constructor(parent, data) {
      this.origin = parent;
      this.scope = new ScopedEval({}, data)
      
      const result = this.scope.eval();

      if (this.scope.error) {
        const errorDiv = document.createElement('div');
        errorDiv.innerText = this.scope.error;
        errorDiv.classList.add('err-js');
        this.origin.element.appendChild(errorDiv);
        return this;
      }

      if (__isElement(result)) {
        this.origin.element.appendChild(result);
        this.scope.after(result);
        return this;
      }
      
      const editor = new window.EditorView({
        doc: String(result),
        extensions: [
          window.highlightSpecialChars(),
          window.EditorState.readOnly.of(true),
          window.javascript(),
          window.syntaxHighlighting(window.defaultHighlightStyle, { fallback: true }),
          window.editorCustomTheme
        ],
        parent: this.origin.element
      });    

      this.scope.after(editor);
      
      return this;
    }
  }
  
  window.SupportedLanguages.push({
    check: (r) => {return(r[0].match(/\w*\.(js)$/) != null)},
    plugins: [window.javascript()],
    name: window.javascriptLanguage.name
  });

  window.SupportedCells['js'] = {
    view: JSCell
  };