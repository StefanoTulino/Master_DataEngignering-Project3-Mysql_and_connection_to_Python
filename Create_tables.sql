# Project of Stefano Tulino

#-------------------------------------------------------------------------

-- Temporary table 1
create temporary table banca.tbl_conto AS (
		SELECT c.id_cliente, count(cont.id_conto) as num_conto,
			count(case 
						when cont.id_tipo_conto=0 then cont.id_tipo_conto else null 
					end) AS num_conto_Base, 
			count(case 
						when cont.id_tipo_conto=1 then cont.id_tipo_conto else null 
					end) AS num_conto_Business,
			count(case 
					when cont.id_tipo_conto=2 then cont.id_tipo_conto else null 
					end) AS num_conto_Privati,
			count(case 
					when cont.id_tipo_conto=3 then cont.id_tipo_conto else null 
					end) AS num_conto_Famiglie
		FROM banca.cliente as c
			left join banca.conto as cont on c.id_cliente=cont.id_cliente
				left join banca.tipo_conto as tipo_c on cont.id_tipo_conto=tipo_c.id_tipo_conto
		group by 1
        order by c.id_cliente
);


-- Temporary table 2
create temporary table banca.tbl_uscita AS (
		SELECT distinct c.id_cliente, TIMESTAMPDIFF(year,c.data_nascita,current_date()) as eta, count(t.data) as num_transazioni_uscita,
			sum(case
				when t.importo is not null then t.importo else 0
			end) as importo_uscita,
			count( case
						when t.id_tipo_trans=3 then t.id_tipo_trans else null
					end) as 'Acquisto su Amazon',
			count( case
						when t.id_tipo_trans=4 then t.id_tipo_trans else null
					end) as 'Rata Mutuo',
			count( case
						when t.id_tipo_trans=5 then t.id_tipo_trans else null
					end) as 'Hotel',
			count( case
						when t.id_tipo_trans=6 then t.id_tipo_trans else null
					end) as 'Biglietto Aereo',
			count( case
						when t.id_tipo_trans=7 then t.id_tipo_trans else null
					end) as 'Supermercato',			
			sum(case 
				when cont.id_tipo_conto=0 and t.importo is not null then t.importo else 0
			end) as 'Conto_Base_Importo_Uscita',
			sum(case 
				when cont.id_tipo_conto=1 and t.importo is not null then t.importo else 0
			end) as 'Conto_Business_Importo_Uscita',
			sum(case 
				when cont.id_tipo_conto=2 and t.importo is not null then t.importo else 0
			end) as 'Conto_Privati_Importo_Uscita',
			sum(case 
				when cont.id_tipo_conto=3 and t.importo is not null then t.importo else 0 
			end) as 'Conto_Famiglie_Importo_Uscita'
				
		FROM banca.cliente c
			left join banca.conto cont on c.id_cliente=cont.id_cliente
			left join banca.tipo_conto tipo_c on cont.id_tipo_conto=tipo_c.id_tipo_conto
				left join banca.transazioni t on cont.id_conto=t.id_conto
					left join (
							select *
								from banca.tipo_transazione tipo_t
							where tipo_t.segno="-") usc
					on t.id_tipo_trans=usc.id_tipo_transazione
		WHERE (usc.segno is not null and cont.id_conto is not null) or (usc.segno is null and cont.id_conto is null)
		group by 1,2
        order by c.id_cliente
);

-- Temporary table 3
create temporary table banca.tbl_entrata AS (
		SELECT distinct c.id_cliente, count(t.data) as num_transazioni_entrata,
			sum(case
				when t.importo is not null then t.importo else 0
			end) as importo_entrata,
			
			count( case
						when t.id_tipo_trans=0 then t.id_tipo_trans else null
					end) as 'Stipendio',
			count( case
						when t.id_tipo_trans=1 then t.id_tipo_trans else null
					end) as 'Pensione',
			count( case
						when t.id_tipo_trans=2 then t.id_tipo_trans else null
					end) as 'Dividendi',
			sum(case 
				when cont.id_tipo_conto=0 and t.importo is not null then t.importo else 0
			end) as 'Conto_Base_Importo_Entrata',
			sum(case 
				when cont.id_tipo_conto=1 and t.importo is not null then t.importo else 0
			end) as 'Conto_Business_Importo_Entrata',
			sum(case 
				when cont.id_tipo_conto=2 and t.importo is not null then t.importo else 0
			end) as 'Conto_Privati_Importo_Entrata',
			sum(case 
				when cont.id_tipo_conto=3 and t.importo is not null then t.importo else 0 
			end) as 'Conto_Famiglie_Importo_Entrata'
					
		FROM banca.cliente c
			left join banca.conto cont on c.id_cliente=cont.id_cliente
			left join banca.tipo_conto tipo_c on cont.id_tipo_conto=tipo_c.id_tipo_conto
				left join banca.transazioni t on cont.id_conto=t.id_conto
					left join (
							select *
								from banca.tipo_transazione tipo_t
							where tipo_t.segno="+") entr
					on t.id_tipo_trans=entr.id_tipo_transazione
		WHERE (entr.segno is not null and cont.id_conto is not null) or (entr.segno is null and cont.id_conto is null)
		group by 1
        order by c.id_cliente
);


-- create table banca.tabella_denormalizzata AS (
create table banca.tabella_denormalizzata AS (
select tb2.*,tb1.num_conto,tb1.num_conto_base, tb1.num_conto_business,tb1.num_conto_privati,tb1.num_conto_famiglie,
tb3.num_transazioni_entrata,tb3.importo_entrata, tb3.stipendio,tb3.pensione,tb3.dividendi,tb3.conto_base_importo_entrata,
tb3.conto_business_importo_entrata,tb3.conto_privati_importo_entrata,tb3.conto_famiglie_importo_entrata
from banca.tbl_conto tb1
join banca.tbl_uscita tb2 on tb1.id_cliente=tb2.id_cliente
join banca.tbl_entrata tb3 on tb1.id_cliente=tb3.id_cliente
);


select * from banca.tbl_conto;
select * from banca.tbl_entrata;
select * from banca.tbl_uscita;

select * from banca.tabella_denormalizzata;
