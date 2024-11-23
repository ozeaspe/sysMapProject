import { LightningElement, track } from 'lwc';
import dadosCliente from '@salesforce/apex/PesquisarCNPJController.dadosCliente';
import salvarDadosCliente from '@salesforce/apex/PesquisarCNPJController.salvarDadosCliente';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CadastrarClientes extends LightningElement {

    @track cnpj = '';
    @track cliente = {
        nome: '',
        cnpj: '',
        logradouro: '',
        numero: '',
        complemento: '',
        bairro: '',
        municipio: '',
        uf: '',
        cep: '',
        telefone: '',
        situacao: ''
    };
    @track errorMessage = '';
    @track accountId;

    //Função para capturar o CNPJ
    handleInputCnpj(event) {
        this.cnpj = event.target.value;
    }

    //Função para fazer a pesquisa
    handlePesquisar() {
        if (this.cnpj) {
            // Chamando o método Apex e passando o CNPJ informado
            dadosCliente({ cnpj: this.cnpj })
                .then((result) => {
                    if(Object.keys(result).length === 0){
                        this.ShowToast('CNPJ inválido ou não encontrado!', 'warning');
                    }else{
                        this.cliente = result;
                        this.errorMessage = '';
                        this.ShowToast('CNPJ localizado com sucesso!', 'success');
                    }
                    console.log(JSON.stringify(result));
                    // Mapeia os dados retornados para os campos correspondentes
                })
                .catch((error) => {
                    // Exibe uma mensagem de erro se a chamada falhar
                    this.cliente = {};
                    this.errorMessage = 'Erro ao consultar CNPJ: ' + (error.body ? error.body.message : error.message);
                    this.ShowToast('Erro ao consultar CNPJ', 'error');
                });
        } else {
            
            this.ShowToast('Informe um CNPJ válido', 'warning');
        }
    }
     
    //Função para inserir um novo cliente
    handleNovoCliente() {
        console.log(JSON.stringify(this.cliente));
        if (this.cliente) {
            salvarDadosCliente({
                nome: this.cliente.nome,
                cnpj: this.cliente.cnpj,
                logradouro: this.cliente.logradouro,
                numero: this.cliente.numero,
                complemento: this.cliente.complemento,
                bairro: this.cliente.bairro,
                municipio: this.cliente.municipio,
                uf: this.cliente.uf,
                cep: this.cliente.cep,
                telefone: this.cliente.telefone,
                situacao: this.cliente.situacao
            })
            .then((result) => {
                this.accountId = result;
                this.errorMessage = '';
                this.ShowToast('Dados salvos com sucesso. ID da Conta: ' + this.accountId, 'success');
            })
            .catch((error) => {
                console.error('Erro ao salvar dados:', error);
               
                this.ShowToast('Erro ao salvar dados: ' + error.body ? error.body.message : error.message,'error');
            });
        } else {
            
            this.ShowToast('Não há dados para salvar. Consulte um CNPJ primeiro.','error')
        }
    }

    //Todas as funções abaixo são atualizar o campo, após a edição.
    handlerChangeNome(event){
        this.cliente.nome = event.target.value;
    }

    handlerChangeCNPJ(event){
        this.cliente.cnpj = event.target.value;
    }

    handlerChangeLogradouro(event){
        this.cliente.logradouro= event.target.value;
    }

    handlerChangeNumero(event){
        this.cliente.numero = event.target.value;
    }

    handlerChangeComplemento(event){
        this.cliente.complemento = event.target.value;
    }

    handlerChangeBairro(event){
        this.cliente.bairro = event.target.value;
    }

    handlerChangeMunicipio(event){
        this.cliente.municipio = event.target.value;
    }

    handlerChangeUf(event){
        this.cliente.uf = event.target.value;
    }

    handlerChangeCep(event){
        this.cliente.cep = event.target.value;
    }

    handlerChangeTelefone(event){
        this.cliente.telefone = event.target.value;
    }

    handlerChangeSituacao(event){
        this.cliente.situacao = event.target.value;
    }

    // Método para exibir o toast
    ShowToast(message, variant) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant, // 'success', 'error', 'warning', 'info'
        });
        this.dispatchEvent(evt); // Dispara o evento de toast
    }

}
