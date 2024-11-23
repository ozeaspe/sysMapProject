@isTest
public class PesquisarCNPJControllerTest {

    // Mock para simular a resposta da API ReceitaWS
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            
            // Simula um JSON de sucesso retornado pela API
            res.setBody('{"nome": "Empresa Teste", "cnpj": "12345678000190", "logradouro": "Rua Exemplo", "numero": "123", "situacao": "Ativa", "complemento": "Sala 5", "cep": "12345-678", "bairro": "Centro", "municipio": "São Paulo", "uf": "SP", "telefone": "123456789"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Classe de Mock para simular uma resposta de erro
    private class MockHttpResponseError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);  // Erro 404, por exemplo
            return res;
        }
    }

    @isTest
    static void testDadosCliente_Sucesso() {
        // Configura o mock de resposta
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Chama o método que consulta a API
        PesquisarCNPJController.CnpjModel result = PesquisarCNPJController.dadosCliente('12345678000190');
        
        // Verifica se os dados foram preenchidos corretamente
        System.assertEquals('Empresa Teste', result.nome);
        System.assertEquals('12345678000190', result.cnpj);
        System.assertEquals('Rua Exemplo', result.logradouro);
        System.assertEquals('123', result.numero);
        System.assertEquals('Ativa', result.situacao);
    }

    @isTest
    static void testDadosCliente_Falha() {
        // Configura o mock para simular uma falha na resposta da API
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());

        // Tenta chamar o método e espera uma exceção
        try {
            PesquisarCNPJController.dadosCliente('00000000000000');
        } catch (Exception e) {
            System.assertEquals('Não foi possível consultar o CNPJ. Verifique e tente novamente.', e.getMessage());
        }
    }

    @isTest
    static void testSalvarDadosCliente_Sucesso() {
        // Chama o método salvarDadosCliente com dados válidos
        String nome = 'Empresa Teste';
        String cnpj = '12345678000190';
        String logradouro = 'Rua Exemplo';
        String numero = '123';
        String complemento = 'Sala 5';
        String bairro = 'Centro';
        String municipio = 'São Paulo';
        String uf = 'SP';
        String cep = '12345-678';
        String telefone = '123456789';
        String situacao = 'Ativa';

        Id contaId = PesquisarCNPJController.salvarDadosCliente(nome, cnpj, logradouro, numero, complemento, bairro, municipio, uf, cep, telefone, situacao);
        
        // Verifica se a conta foi criada com sucesso
        Account conta = [SELECT Name, CNPJ__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone, Status_Cadastral__c FROM Account WHERE Id = :contaId];
        System.assertEquals(nome, conta.Name);
        System.assertEquals(cnpj, conta.CNPJ__c);
        System.assertEquals(logradouro + ' ' + numero + ' ' + complemento + ' ' + bairro, conta.BillingStreet);
        System.assertEquals(municipio, conta.BillingCity);
        System.assertEquals(uf, conta.BillingState);
        System.assertEquals(cep, conta.BillingPostalCode);
        System.assertEquals(telefone, conta.Phone);
        System.assertEquals(situacao, conta.Status_Cadastral__c);
    }

    /*@isTest
    static void testSalvarDadosCliente_Erro() {
        // Testa a validação quando o nome está vazio
        try {
            PesquisarCNPJController.salvarDadosCliente('', '12.345.678/0001-90', 'Rua Exemplo', '123', '', 'Centro', 'São Paulo', 'SP', '12345-678', '123456789', 'Ativa');
            System.assert(false, 'Exceção esperada para nome vazio');
        } catch (Exception e) {
            System.assertEquals('O nome do cliente é obrigatório.', e.getMessage());
        }

        // Testa a validação quando o CNPJ está em um formato incorreto
        try {
            PesquisarCNPJController.salvarDadosCliente('Empresa Teste', '123', 'Rua Exemplo', '123', '', 'Centro', 'São Paulo', 'SP', '12345-678', '123456789', 'Ativa');
            System.assert(false, 'Exceção esperada para CNPJ inválido');
        } catch (Exception e) {
            System.assertEquals('O CNPJ é obrigatório e deve conter 14 caracteres.', e.getMessage());
        }
    }*/
}