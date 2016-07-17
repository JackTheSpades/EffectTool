using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Diagnostics;

namespace HDMA_Generator_Tool
{
	public partial class ShowCode : Form
	{
		public string Code { get; set; }
		public bool UsesMain { get; set; }

		public ShowCode() : this("") { }
		public ShowCode(string code)
		{
			InitializeComponent();
			this.Code = code;

			if(Code.Contains(EffectClasses.HDMA.MAINSeperator))
			{
				string[] split = code.Split(new[] { EffectClasses.HDMA.MAINSeperator }, StringSplitOptions.None);
				rtbInit.Text = split[0];
				rtbMain.Text = split[1].TrimStart('\n','\r');
			}
			else
			{
				rtbInit.Text = code;
				spcCode.Panel2Collapsed = true;
				MinimumSize = new Size(256, this.MinimumSize.Height);
				btnMainToClip.Visible = false;
				btnInitToClip.Text = "Copy to Clipboard";
			}
		}

		public static void ShowCodeDialog(string code)
		{
			try
			{
				if (code == null || code == String.Empty)
					return;
				new ShowCode(code).ShowDialog();
			}
			catch(Exception ex)
			{
				ShowMessage(ex);
			}
		}

		public static void ShowCodeDialog(params EffectClasses.ICodeProvider[] providers)
		{
			try
			{
				string code = "";
				foreach (var provider in providers)
				{
					string single = provider.Code();
					if (single == null || single == String.Empty)
						return;
					code += single + "\n";
				}
				new ShowCode(code).ShowDialog();
			}
			catch (Exception ex)
			{
				ShowMessage(ex);
			}
		}


		public static void ShowMessage(Exception ex)
		{
			MessageBox.Show(ex.Message, "Can't Generate Code", MessageBoxButtons.OK, MessageBoxIcon.Error);
		}

		private void btnInitToClip_Click(object sender, EventArgs e)
		{
			Clipboard.SetText(rtbInit.Text.Replace("\n", "\r\n"));
		}
		private void btnMainToClip_Click(object sender, EventArgs e)
		{
			Clipboard.SetText(rtbMain.Text.Replace("\n", "\r\n"));
		}
		
		private void btn_AsASM_Click(object sender, EventArgs e)
		{
			SaveFileDialog SFD = new SaveFileDialog();
			SFD.Filter = "xkas patch (*.asm)|*.asm|asar patch (*.asm)|*.asm|SpriteTool generator (*.asm)|*.asm";
			SFD.DefaultExt = ".asm";
			if (SFD.ShowDialog() == System.Windows.Forms.DialogResult.Cancel)
				return;

			string path = Path.GetDirectoryName(SFD.FileName) + "\\" + 
				Path.GetFileName(SFD.FileName).Replace(' ', '_');

			System.Windows.Forms.DialogResult res = System.Windows.Forms.DialogResult.OK;

			do
			{
				try
				{
					if (SFD.FilterIndex == 1) //xkas
					{
						string CodeToPrint = ";@xkas\n" +
							";To be patched with xkas or asar.\n\n" +
							"header\n" +
							"lorom\n" +
							"ORG $128000\t;<-- Change this to some freespace.\n\n" +
							";this is RATS tag, if you don't know what this is, don't touch it!!!\n" +
							"db \"STAR\"\n" +
							"dw RATS_End-RATS_Start-$01\n" +
							"dw RATS_End-RATS_Start-$01^$FFFF\n\n" +
							"RATS_Start:\n" +
							Code + "\nRATS_End:";

						CodeToPrint = CodeToPrint.Replace(EffectClasses.HDMA.INITLabel,
							"print \"For the INIT code, JSL to $\",pc\n" + EffectClasses.HDMA.INITLabel);
						CodeToPrint = CodeToPrint.Replace(EffectClasses.HDMA.MAINLabel,
							"print \"For the MAIN code, JSL to $\",pc\n" + EffectClasses.HDMA.MAINLabel);

						CodeToPrint = CodeToPrint.Replace("RTS", "RTL");
						File.WriteAllText(path, CodeToPrint);
					}
					else if (SFD.FilterIndex == 2) //asar
					{
						string CodeToPrint = "; To be patched with asar.\n\n" +
							"header\n" +
							"lorom\n\n" +
							";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n" +
							"; A SMALL WARNING\n" +
							"; using asar and it's freespace logging function to insert this code might be convinient,\n" +
							"; but due to there being no JSL and thus no autoclean command, asar will print a warning,\n" +
							"; that the freespace appears to be leaked. This means it cannot be deleted by asar!\n" +
							"; This also further means, that if you apply this patch multiple times, you'll lose freespace\n" +
							"; Use onyl once... or with the needed care. YOU HAVE BEEN WARNED\n" +
							";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n" +

							"freecode\n" +
							"CodeLabel:\n\n" +
							Code;

						CodeToPrint = CodeToPrint.Replace(EffectClasses.HDMA.INITLabel,
							"print \"For the INIT code, JSL to $\",pc\n" + EffectClasses.HDMA.INITLabel);
						CodeToPrint = CodeToPrint.Replace(EffectClasses.HDMA.MAINLabel,
							"print \"For the MAIN code, JSL to $\",pc\n" + EffectClasses.HDMA.MAINLabel);

						CodeToPrint = CodeToPrint.Replace("RTS", "RTL");
						File.WriteAllText(path, CodeToPrint);
					}
					else
					{
						string CodeToPrint = "; To be inserted as generator with SpriteTool (as number D0 - FF).\n\n" +
							"print \"INIT \",pc\n" +
							"print \"MAIN \",pc\n" +
							"PHB : PHK : PLB\nJSR Sprite\nPLB\nRTL\n" +
							"\n\nSprite:\n\n" + Code;

						string CFG = "03\n" +
							"FF\n" +
							"FF FF FF FF FF FF\n" +
							"FF FF\n" +
							Path.GetFileName(path) + "\n" +
							"1";

						File.WriteAllText(path, CodeToPrint);
						File.WriteAllText(path.Substring(0, path.Length - 3) + "cfg", CFG);
					}
				}
				catch (Exception ex)
				{
					res = MessageBox.Show("Saving has failed due to reasons such as those listed below:\n\n"
						+ ex.Message, "No Save", MessageBoxButtons.RetryCancel, MessageBoxIcon.Error);
				}
			} while (res == System.Windows.Forms.DialogResult.Retry);
		}
	}
}
