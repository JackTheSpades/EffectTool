using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace HDMA_Generator_Tool
{
	public partial class MultiLayerCreator : Form
	{
		public bool Edit { get; private set; }
		public EffectClasses.BitmapCollection GeneratedCollection { get; set; }

		private Dictionary<Control, Control> _buttonImageCoOp = new Dictionary<Control, Control>();
		private EffectClasses.ColorMath _colMath = new EffectClasses.ColorMath();

		public MultiLayerCreator()
		{
			InitializeComponent();
			_buttonImageCoOp.Add(btnBG1Load, pcbBG1);
			_buttonImageCoOp.Add(btnBG2Load, pcbBG2);
			_buttonImageCoOp.Add(btnBG3Load, pcbBG3);
			_buttonImageCoOp.Add(btnBG4Load, pcbBG4);
			_buttonImageCoOp.Add(btnOBJLoad, pcbOBJ);

			_buttonImageCoOp.Add(btnBG1Save, pcbBG1);
			_buttonImageCoOp.Add(btnBG2Save, pcbBG2);
			_buttonImageCoOp.Add(btnBG3Save, pcbBG3);
			_buttonImageCoOp.Add(btnBG4Save, pcbBG4);
			_buttonImageCoOp.Add(btnOBJSave, pcbOBJ);


			_colMath.FixedColor = new Bitmap(256, EffectClasses.HDMA.Scanlines);
			DialogResult = System.Windows.Forms.DialogResult.Cancel;
		}

		private void UpdateScreen()
		{
			try
			{
				_colMath.FixedColor.Dispose();

				_colMath.BG1 = new Bitmap(pcbBG1.Image, Settings.DefaultSize);
				_colMath.BG2 = new Bitmap(pcbBG2.Image, Settings.DefaultSize);
				_colMath.BG3 = new Bitmap(pcbBG3.Image, Settings.DefaultSize);
				_colMath.BG4 = new Bitmap(pcbBG4.Image, Settings.DefaultSize);
				_colMath.OBJ = new Bitmap(pcbOBJ.Image, Settings.DefaultSize);
				_colMath.FixedColor
					= EffectClasses.BitmapEffects.FromColor(
					pcbCol.BackColor, Settings.DefaultSize);

				pcbMain.Image = _colMath.GetScreen();
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.Message, "Something went wrong.", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void btnLoadPic_Click(object sender, EventArgs e)
		{
			Screenshot.Load((IM => ((PictureBox)_buttonImageCoOp[(Control)sender]).Image = IM), UpdateScreen);
		}

		private void btnLoad_Click(object sender, EventArgs e)
		{
			OpenFileDialog dialog = new OpenFileDialog();
			dialog.Filter = "Mutilayer *.ml|*.ml";
			dialog.Title = "Multilayer Open File";
			dialog.InitialDirectory = Path.GetFullPath(Settings.MultilayerFolder);

			if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.Cancel)
				return;

			try
			{
				EffectClasses.BitmapCollection collection = EffectClasses.BitmapCollection.Load(dialog.FileName);
				pcbBG1.Image = collection.BG1;
				pcbBG2.Image = collection.BG2;
				pcbBG3.Image = collection.BG3;
				pcbBG4.Image = collection.BG4;
				pcbOBJ.Image = collection.OBJ;
				pcbCol.BackColor = collection.FixedColor;

				_colMath.Collection = collection;
				_colMath.FixedColor = EffectClasses.BitmapEffects.FromColor(
					collection.FixedColor, Settings.DefaultSize);
				txtName.Text = collection.Name;
				pcbMain.Image = _colMath.GetScreen();
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.Message, "Couldn't open file", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void btnSave_Click(object sender, EventArgs e)
		{
			DirectoryInfo directory = new DirectoryInfo(Settings.MultilayerFolder);
			FileInfo[] files = directory.GetFiles("*.ml");
			if (files.Any(f => f.Name.ToLower() == txtName.Text.ToLower() + ".ml"))
			{
				if(MessageBox.Show("A Multilayer with the given name already exists.\nDo you want to overwrite it?", "Conflict", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == System.Windows.Forms.DialogResult.Cancel)
					return;
				Edit = true;
			}

			try
			{
				GeneratedCollection = _colMath.Collection;
				GeneratedCollection.FixedColor = pcbCol.BackColor;
				GeneratedCollection.Name = txtName.Text;
				EffectClasses.BitmapCollection.Save(GeneratedCollection, directory.Name + "\\" + txtName.Text + ".ml");
				DialogResult = System.Windows.Forms.DialogResult.OK;
				Close();
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.Message, "Couldn't save file", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void btnSavePic_Click(object sender, EventArgs e)
		{
			try
			{
				SaveFileDialog sfd = new SaveFileDialog();
				sfd.DefaultExt = "png";
				sfd.Filter = "PNG | *.png";
				if (sfd.ShowDialog() == System.Windows.Forms.DialogResult.Cancel)
					return;

				((PictureBox)_buttonImageCoOp[(Control)sender]).Image.Save(sfd.FileName);
			}
			catch(Exception ex)
			{
				MessageBox.Show("Something went wrong with saving!\n\n" + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void pcbCol_Click(object sender, EventArgs e)
		{
			ColorDialog cd = new ColorDialog();
			cd.FullOpen = true;
			cd.Color = pcbCol.BackColor;

			if (cd.ShowDialog() == System.Windows.Forms.DialogResult.Cancel)
				return;

			pcbCol.BackColor = cd.Color;
			UpdateScreen();
		}
	}

	public static class LayerManager
	{
		/// <summary>
		/// Asign the Bitmaps to a ColorMath object from a ComboBox.
		/// </summary>
		/// <param name="Math">The ColorMath that will get the images assigned to it.</param>
		/// <param name="Selector">The ComboBox containing BitmapCollection objects.</param>
		public static void AsignLayers(EffectClasses.ColorMath Math, object Selector)
		{
			AsignLayers(Math, Selector, true);
		}

		/// <summary>
		/// Asign the Bitmaps to a ColorMath object from a ComboBox.
		/// </summary>
		/// <param name="Math">The ColorMath that will get the images assigned to it.</param>
		/// <param name="Selector">The ComboBox containing BitmapCollection objects.</param>
		/// <param name="dontColor"><c>True</c> will overwrite the FixedColor property of the ColorMath with the one from the BitmapCollection.</param>
		public static void AsignLayers(EffectClasses.ColorMath Math, object Selector, bool setColor)
		{
			//The first Object is the option to use a screenshot.
			if (((ComboBox)Selector).SelectedIndex == 0)
			{
				MessageBox.Show("This feature is currently not available.", "Not Implemented", MessageBoxButtons.OK, MessageBoxIcon.Information);
				((ComboBox)Selector).SelectedIndex = 1;
			}
			
			EffectClasses.BitmapCollection bc = (EffectClasses.BitmapCollection)((ComboBox)Selector).SelectedItem;
			Math.Collection = bc;
			if (setColor)
			{
				if (bc.FixedColor == null)
					bc.FixedColor = Color.Transparent;
				Math.FixedColor = EffectClasses.BitmapEffects.FromColor(bc.FixedColor, bc.BG1.Size);
			}
		}
	}
}
