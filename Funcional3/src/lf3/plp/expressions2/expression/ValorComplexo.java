package lf3.plp.expressions2.expression;

import lf3.plp.expressions1.util.Tipo;
import lf3.plp.expressions1.util.TipoPrimitivo;
import lf3.plp.expressions2.memory.AmbienteCompilacao;
import lf3.plp.expressions2.memory.AmbienteExecucao;
import lf3.plp.expressions2.memory.VariavelJaDeclaradaException;
import lf3.plp.expressions2.memory.VariavelNaoDeclaradaException;

/**
 * Objetos desta classe encapsulam um numero complexo <code>a + bi</code>.
 * As partes real e imaginaria sao <code>Valor</code>es ja avaliados (hoje
 * <code>ValorInteiro</code>), o que permite acomodar valores simbolicos
 * depois. Objetos desta classe sao imutaveis.
 */
public class ValorComplexo implements Valor {

	private final Valor real;

	private final Valor imag;

	/**
	 * Cria <code>ValorComplexo</code> com as partes fornecidas.
	 * 
	 * @param real a parte real ja avaliada.
	 * @param imag a parte imaginaria ja avaliada.
	 */
	public ValorComplexo(Valor real, Valor imag) {
		this.real = real;
		this.imag = imag;
	}

	public Valor getReal() {
		return real;
	}

	public Valor getImag() {
		return imag;
	}

	/**
	 * Promove um valor a complexo: um <code>ValorComplexo</code> e retornado
	 * como esta; um inteiro <code>a</code> vira <code>complex(a, 0)</code>.
	 */
	public static ValorComplexo promover(Valor valor) {
		if (valor instanceof ValorComplexo) {
			return (ValorComplexo) valor;
		}
		return new ValorComplexo(valor, new ValorInteiro(0));
	}

	/**
	 * Soma de dois complexos: <code>(a + bi) + (c + di) = (a + c) + (b + d)i</code>.
	 */
	public static ValorComplexo soma(ValorComplexo esq, ValorComplexo dir, AmbienteExecucao amb)
			throws VariavelNaoDeclaradaException, VariavelJaDeclaradaException {
		return new ValorComplexo(
			new ExpSoma(esq.real, dir.real).avaliar(amb),
			new ExpSoma(esq.imag, dir.imag).avaliar(amb));
	}

	/**
	 * Retorna o proprio valor.
	 */
	public Valor avaliar(AmbienteExecucao amb) {
		return this;
	}

	/**
	 * Sempre valido.
	 */
	public boolean checaTipo(AmbienteCompilacao amb) {
		return true;
	}

	public Tipo getTipo(AmbienteCompilacao amb) {
		return TipoPrimitivo.COMPLEXO;
	}

	public Expressao reduzir(AmbienteExecucao ambiente) {
		return this;
	}

	@Override
	public ValorComplexo clone() {
		return new ValorComplexo((Valor) real.clone(), (Valor) imag.clone());
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null || getClass() != obj.getClass())
			return false;
		ValorComplexo other = (ValorComplexo) obj;
		return real.equals(other.real) && imag.equals(other.imag);
	}

	@Override
	public int hashCode() {
		return 31 * real.hashCode() + imag.hashCode();
	}

	@Override
	public String toString() {
		return String.format("complex(%s, %s)", real, imag);
	}
}
