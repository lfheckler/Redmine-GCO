//abre o div para criação de nova baseline
function divBaselineShow(){
    document.getElementById("divBaselineForm").style.display = "";
    document.getElementById("divBtBaselineForm").style.display = "none";
    document.getElementById("user").focus();
}

//usado nos formulários para desabilitar o botão e exibir mensagem de carregando
function onSubmitButton(button_id){
    document.getElementById(button_id).disabled = true;
    Element.show('ajax-indicator');
}

//validação do form de nova baseline planejada
function onSubmitNewBaselinePlan(){
    if(document.getElementById("baseline_ident").replace(" ", "").value==""){
        alert("O identificador da baseline deve ser preenchido.");
        return false;
    } else {
        return true;
    }
}

function alternaDiv(span, div){
    elDiv = $(div);
    elSpan = $(span);
    if (elDiv.hasClassName('opened')) {
        elDiv.addClassName('closed');
        elDiv.removeClassName('opened');
        elSpan.addClassName('expand');
        elSpan.removeClassName('collapse');
    } else if (elDiv.hasClassName('closed')) {
        elDiv.addClassName('opened');
        elDiv.removeClassName('closed');
        elSpan.addClassName('collapse');
        elSpan.removeClassName('expand');
    }

}


function showIssuesDiv(changeset, revision){
    elDiv = $('divSelectIssue');
    elDiv.style.display = "";
    labelRev = $('labelRevision');
    labelRev.textContent = revision;
    document.getElementById('changeset_id').value = changeset;
}

function hideIssuesDiv(){
    elDiv = $('divSelectIssue');
    elDiv.style.display = "none";
}

function issueBaselineRelation(id,project_id){

    if($(id).checked){
        new Ajax.Request('/gco_issue/add', {asynchronous:true, evalScripts:true, method:'post', parameters:{issue_id: $('issue_id').value,baseline_id: $(id).value,project_id:project_id}});
    } else {
        new Ajax.Request('/gco_issue/del', {asynchronous:true, evalScripts:true, method:'post', parameters:{issue_id: $('issue_id').value,baseline_id: $(id).value,project_id:project_id}});
    }
}


function issueChangesetRelation(changeset_id,project_id){

    if($(changeset_id).checked){
        new Ajax.Request('/issue_revision/add', {asynchronous:true, evalScripts:true, method:'post', parameters:{issue_id: $('issue_id').value,changeset_id: $(changeset_id).value,project_id:project_id}});
    } else {
        new Ajax.Request('/issue_revision/del', {asynchronous:true, evalScripts:true, method:'post', parameters:{issue_id: $('issue_id').value,changeset_id: $(changeset_id).value,project_id:project_id}});
    }
}


function addCss(){
    l = document.createElement('link');
    l.href = "/plugin_assets/redmine_gco/stylesheets/gco.css";
    l.type = "text/css";
    l.rel = "stylesheet";
    l.media = "all";
    document.getElementsByTagName("head")[0].appendChild(l);
}

function showBaselineItems(){
    new Ajax.Request('/baseline/baseline_items', {asynchronous:true, evalScripts:true, method:'post', parameters:{baseline_id: $('baseline_id').value,project_id: $('project_id').value}});
}

function showIssueRevisions(){
    new Ajax.Request('/issue_revision/show_revisions', {asynchronous:true, evalScripts:true, method:'post', parameters:{issue_id: $('issue_id').value,project_id: $('project_id').value}});
}