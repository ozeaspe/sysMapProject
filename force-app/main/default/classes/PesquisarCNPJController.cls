public with sharing class PesquisarCNPJController {
    @AuraEnabled
    public static CnpjModel dadosCliente(String cnpj) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Configurando o endpoint
        request.setEndpoint('https://www.receitaws.com.br/v1/cnpj/' + cnpj);
        request.setMethod('GET');

        CnpjModel results = new CnpjModel();

        try {
            HttpResponse response = http.send(request);
            System.debug('Resposta JSON: ' + response.getBody()); // Debug do JSON bruto

            if (response.getStatusCode() == 200) {
                // Desserializando a resposta JSON para o objeto CnpjModel
                results = (CnpjModel) JSON.deserialize(response.getBody(), CnpjModel.class);
                System.debug('Dados retornados: ' + results);
                System.debug('Nome: ' + results.nome);
                System.debug('Município: ' + results.municipio);
                return results;
            } 
        } catch (Exception e) {
            System.debug('Erro ao consultar API: ' + e.getMessage());
            throw new AuraHandledException('Não foi possível consultar o CNPJ. Verifique e tente novamente.');
        }

        return results;
    }

    // Método para salvar os dados retornados no objeto Account
    @AuraEnabled
    
    public static Id salvarDadosCliente(String nome, String cnpj, String logradouro, String numero, String complemento, String bairro,
                                            String municipio, String uf, String cep, String telefone, String situacao) {
                                                System.debug('### Início do método salvarDadosCliente');
    
    // Validação dos dados
    if (String.isBlank(nome)) {
        throw new AuraHandledException('O nome do cliente é obrigatório.');
    }
    if (String.isBlank(cnpj) || (cnpj.length() < 14 || cnpj.length() == 14)) {
    throw new AuraHandledException('O CNPJ é obrigatório e deve conter 14 caracteres.');
    }

        // Cria um novo cliente com os dados recebidos
        Account conta = new Account();
        conta.Name = nome;
        conta.CNPJ__c = cnpj; 
        conta.BillingStreet = logradouro + ' ' + numero + ' ' + complemento + ' ' + bairro;
        conta.BillingCity = municipio;
        conta.BillingState = uf;
        conta.BillingPostalCode = cep;
        conta.Phone = telefone;
        conta.Status_Cadastral__c =situacao;
        
        try {
            // Insere a conta e retorna o ID gerado
            insert conta;
            System.debug('### Conta inserida com sucesso, ID: ' + conta.Id);
            return conta.Id;
        } catch (DmlException e) {
            System.debug('### Erro ao inserir dado: ' + e.getMessage());
            String msgError = e.getMessage();
            if (e.getMessage().contains('DUPLICATES_DETECTED')) {
                msgError = 'CNPJ já cadastrado!';
            }
            throw new AuraHandledException(msgError);
        }
        
    }

    public class CnpjModel {
        @AuraEnabled public String nome;
        @AuraEnabled public String cnpj;
        @AuraEnabled public String logradouro;
        @AuraEnabled public String numero;
        @AuraEnabled public String situacao;
        @AuraEnabled public String complemento;
        @AuraEnabled public String cep;
        @AuraEnabled public String bairro;
        @AuraEnabled public String municipio;
        @AuraEnabled public String uf;
        @AuraEnabled public String telefone;
    }


}