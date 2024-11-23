global with sharing class ConsultarCNPJAPI { 

    // Modelo de Dados para a Resposta da API
    global class CNPJModel {
        @InvocableVariable global String nome;
        @InvocableVariable global String cnpj;
        @InvocableVariable global String logradouro;
        @InvocableVariable global String numero;
        @InvocableVariable global String situacao;
        @InvocableVariable global String complemento;
        @InvocableVariable global String cep;
        @InvocableVariable global String bairro;
        @InvocableVariable global String municipio;
        @InvocableVariable global String uf;
        @InvocableVariable global String telefone;
    }

    // Método Invocável para Criação de Conta a partir do CNPJ
    @InvocableMethod(label='Criar Conta')
    public static List<Id> criarContaPeloCNPJ(List<String> cnpjs) {
        List<Id> contaIds = new List<Id>();

        for (String cnpj : cnpjs) {
            // Configurando a URL da API com Named Credential
            String endpoint = '/v1/cnpj/' + cnpj;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ReceitaWS' + endpoint);
            request.setMethod('GET');
            request.setTimeout(60000);

            try {
                // Envio da Solicitação HTTP
                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200) {
                    // Desserialização do JSON para o Modelo CNPJModel
                    CNPJModel apiResponse = (CNPJModel) JSON.deserialize(response.getBody(), CNPJModel.class);

                    // Criação do Registro de Conta
                    Account newAccount = new Account();
                    newAccount.Name = apiResponse.nome != null ? apiResponse.nome : 'Empresa sem Nome';
                    newAccount.CNPJ__c = apiResponse.cnpj;
                    newAccount.BillingStreet = apiResponse.logradouro + ' ' + apiResponse.numero + ' ' + apiResponse.complemento + ' ' + apiResponse.bairro;
                    newAccount.BillingCity = apiResponse.municipio;
                    newAccount.BillingState = apiResponse.uf;
                    newAccount.BillingPostalCode = apiResponse.cep;
                    newAccount.Phone = apiResponse.telefone;
                    newAccount.Status_Cadastral__c = apiResponse.situacao;

                    // Inserindo a Conta e adicionando o ID à lista de retorno
                    insert newAccount;
                    contaIds.add(newAccount.Id);
                } else {
                    // Tratamento de erro para códigos de status diferentes de 200
                    System.debug('Erro na chamada da API. Status: ' + response.getStatusCode() + ' - ' + response.getBody());
                }
            } catch (Exception e) {
                // Tratamento de exceção para erros de chamada externa
                System.debug('Erro ao chamar a API: ' + e.getMessage());
            }
        }
        return contaIds;
    }
}